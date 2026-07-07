const axios = require("axios");
const BaseErpAdapter = require("./baseAdapter");

class SgpAdapter extends BaseErpAdapter {
  constructor(config) {
    super(config);
    this.baseUrl = config.apiBaseUrl.replace(/\/+$/, "");
    this.username = config.apiToken;
    this.password = config.apiSecret;
    this._jar = {};
  }

  _updateJar(setCookieHeaders) {
    if (!setCookieHeaders) return;
    const list = Array.isArray(setCookieHeaders) ? setCookieHeaders : [setCookieHeaders];
    for (const c of list) {
      const m = c.match(/^([^=]+)=([^;]+)/);
      if (m) this._jar[m[1]] = m[2];
    }
  }

  _cookieStr() {
    return Object.entries(this._jar).map(([k, v]) => `${k}=${v}`).join("; ");
  }

  async _ensureLogin() {
    if (this._jar.sessionid) return;

    // Step 1: GET login page to get CSRF cookie + token
    const step1 = await axios.get(`${this.baseUrl}/accounts/login/`, {
      maxRedirects: 0,
      validateStatus: (s) => s < 400,
      headers: { "User-Agent": "Mozilla/5.0" },
    });
    this._updateJar(step1.headers["set-cookie"]);

    const html = step1.data;
    const csrfMatch = html.match(/csrfmiddlewaretoken.*?value=['"]([^'"]+)['"]/);
    if (!csrfMatch) throw new Error("Nao foi possivel extrair CSRF token do SGP");
    const csrf = csrfMatch[1];

    // Step 2: POST login - do NOT follow redirect to capture sessionid cookie
    const loginRes = await axios.post(`${this.baseUrl}/accounts/login/`,
      new URLSearchParams({
        username: this.username,
        password: this.password,
        csrfmiddlewaretoken: csrf,
        next: "/admin/",
      }).toString(),
      {
        maxRedirects: 0,
        validateStatus: (s) => s < 400 || s === 302,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Cookie": this._cookieStr(),
          "Referer": `${this.baseUrl}/accounts/login/`,
          "User-Agent": "Mozilla/5.0",
        },
      }
    );
    this._updateJar(loginRes.headers["set-cookie"]);

    // If redirect, follow it to complete auth
    if (loginRes.status === 302 && loginRes.headers.location) {
      await axios.get(`${this.baseUrl}${loginRes.headers.location}`, {
        maxRedirects: 0,
        validateStatus: (s) => s < 400 || s === 302,
        headers: {
          "Cookie": this._cookieStr(),
          "User-Agent": "Mozilla/5.0",
        },
      });
    }

    if (!this._jar.sessionid) {
      throw new Error("Falha no login SGP - sessionid nao recebido");
    }
  }

  async _get(path) {
    await this._ensureLogin();
    const res = await axios.get(`${this.baseUrl}${path}`, {
      maxRedirects: 5,
      headers: {
        "Cookie": this._cookieStr(),
        "User-Agent": "Mozilla/5.0",
      },
    });
    this._updateJar(res.headers["set-cookie"]);
    return res.data;
  }

  async getClientePorCpf(cpf) {
    const cleanCpf = cpf.replace(/\D/g, "");
    const data = await this._get(`/public/autocomplete/ClienteAutocomplete/?tconsulta=cpfcnpj&term=${cleanCpf}`);
    const list = typeof data === "string" && data.startsWith("[") ? JSON.parse(data) : Array.isArray(data) ? data : [];
    if (list.length === 0) return null;
    const item = list[0];
    return {
      codigo: String(item.id),
      nome: item.label?.split(" - ")[0]?.trim() || "",
      cpfCnpj: cleanCpf,
      email: "",
      telefone: "",
    };
  }

  async getCliente(codigoCliente) {
    const html = await this._get(`/admin/cliente/${codigoCliente}/edit/`);
    const nome = this._extract(html, /Nome\/Razão Social:\s*<span[^>]*>([^<]+)<\/span>/);
    const cpf = this._extract(html, /CPF\/CNPJ:\s*<span[^>]*>\s*([^<]+)\s*<\/span>/);
    const email = this._extract(html, /name="email"[^>]*value="([^"]*)"/);
    const tel = this._extract(html, /name="telefone"[^>]*value="([^"]*)"/);
    return {
      codigo: String(codigoCliente),
      nome: nome?.trim() || "",
      cpfCnpj: cpf?.replace(/\D/g, "") || "",
      email: email || "",
      telefone: tel || "",
    };
  }

  _extract(html, regex) {
    const m = html.match(regex);
    return m ? m[1].trim() : "";
  }

  async getFaturaAberta(codigoCliente) {
    const boletos = await this.getHistoricoFinanceiro(codigoCliente);
    const abertos = boletos.filter(b => b.status === "aberto");
    return abertos.length > 0 ? abertos[0] : null;
  }

  async getHistoricoFinanceiro(codigoCliente) {
    const html = await this._get(`/admin/financeiro/cliente/${codigoCliente}/titulos/`);
    return this._extractBoletos(html);
  }

  _extractBoletos(html) {
    const boletos = [];
    const tableMatch = html.match(/<table\s+class="tablelisttituloA[^"]*"[^>]*>[\s\S]*?<\/table>/i);
    if (!tableMatch) return boletos;
    const table = tableMatch[0];
    const rowRegex = /<tr[^>]*data-dias="([^"]*)"[^>]*data-contrato="([^"]*)"[^>]*>[\s\S]*?<\/tr>/g;
    let m;
    while ((m = rowRegex.exec(table)) !== null) {
      const row = m[0];
      const dias = parseInt(m[1]) || 0;
      const contrato = m[2];

      const cells = row.match(/<td[^>]*>[\s\S]*?<\/td>/g) || [];
      if (cells.length < 8) continue;

      const checkboxHtml = cells[0];
      const idMatch = checkboxHtml.match(/value="(\d+)"/);
      if (!idMatch) continue;
      const tituloId = idMatch[1];

      const nDoc = this._stripHtml(cells[2] || "");
      const emissao = this._stripHtml(cells[3] || "");
      const vencimento = this._stripHtml(cells[4] || "");
      const valorStr = this._stripHtml(cells[6] || "");
      const valorCorrigido = this._stripHtml(cells[7] || "");

      const valNum = parseFloat((valorCorrigido || valorStr).replace(/[R$\s.]/g, "").replace(",", "."));
      if (isNaN(valNum)) continue;

      const pixMatch = row.match(/color:#05a193.*?PIX/i);
      const regMatch = row.match(/Reg\./i);
      const modo = pixMatch ? (regMatch ? "PIX" : "PIX") : "Boleto";

      const boletoUrl = this._extractHref(row, /\/admin\/financeiro\/titulo\/print\/documento\/\?q=\d+/);
      const pixUrl = this._extractHref(row, /\/admin\/financeiro\/pix\/print\/documento\/\?q=\d+/);

      const status = dias < 0 ? "vencido" : "aberto";

      boletos.push({
        id: tituloId,
        numeroDocumento: nDoc,
        valor: valNum,
        vencimento,
        emissao,
        status,
        contrato,
        diasVencido: dias,
        modo,
        linkBoleto: boletoUrl ? `${this.baseUrl}${boletoUrl}` : null,
        linkPix: pixUrl ? `${this.baseUrl}${pixUrl}` : null,
      });
    }
    return boletos;
  }

  _extractHref(html, regex) {
    const m = html.match(regex);
    return m ? m[0] : null;
  }

  _stripHtml(str) {
    return str.replace(/<[^>]*>/g, "").trim().replace(/\s+/g, " ");
  }

  async getChavePix(codigoCliente, faturaId) {
    try {
      const html = await this._get(`/admin/financeiro/pix/print/documento/?q=${faturaId}`);
      const pixMatch = html.match(/(?:pix|copia[ -]?cola)[:=]\s*([0-9a-fA-F]{32,})/i);
      return pixMatch ? pixMatch[1] : null;
    } catch {
      return null;
    }
  }

  async getStatusConexao(codigoCliente) {
    return { online: false, status: "indisponivel" };
  }

  async desbloquearConfianca(codigoCliente) {
    return { sucesso: true, mensagem: "Desbloqueio realizado" };
  }

  async getDadosSuporte() {
    return {
      whatsapp: "(81) 99123-9032",
      email: "suporte@redemeganet.com.br",
      telefone: "0800 XXX XXXX",
    };
  }
}

module.exports = SgpAdapter;
