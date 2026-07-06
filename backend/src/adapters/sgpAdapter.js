const axios = require("axios");
const BaseErpAdapter = require("./baseAdapter");

class SgpAdapter extends BaseErpAdapter {
  constructor(config) {
    super(config);
    this.client = axios.create({
      baseURL: config.apiBaseUrl.replace(/\/+$/, ""),
      headers: {
        "Content-Type": "application/json",
        "api_key": config.apiToken,
        "api_secret": config.apiSecret || "",
      },
      timeout: 30000,
    });
  }

  async _get(endpoint) {
    const response = await this.client.get(endpoint);
    return response.data;
  }

  async _post(endpoint, data) {
    const response = await this.client.post(endpoint, data);
    return response.data;
  }

  async getCliente(codigoCliente) {
    const data = await this._get(`/clientes/${codigoCliente}`);
    return data
      ? {
          codigo: data.id,
          nome: data.nome,
          cpfCnpj: data.documento,
          email: data.email,
          telefone: data.telefone,
        }
      : null;
  }

  async getFaturaAberta(codigoCliente) {
    const data = await this._get(`/clientes/${codigoCliente}/faturas/abertas`);
    const faturas = data?.faturas || [];
    if (faturas.length === 0) return null;

    const fatura = faturas[0];
    return {
      id: fatura.id,
      valor: parseFloat(fatura.valor),
      vencimento: fatura.vencimento,
      status: "aberto",
      mesReferencia: fatura.referencia,
      linkBoleto: fatura.link_boleto || null,
      pixCopiaECola: fatura.pix_copia_cola || null,
    };
  }

  async getHistoricoFinanceiro(codigoCliente) {
    const data = await this._get(`/clientes/${codigoCliente}/faturas`);
    const faturas = data?.faturas || [];
    return faturas.map((f) => ({
      id: f.id,
      valor: parseFloat(f.valor),
      vencimento: f.vencimento,
      pagamento: f.data_pagamento || null,
      status: f.status,
      mesReferencia: f.referencia,
    }));
  }

  async getChavePix(codigoCliente, faturaId) {
    const data = await this._get(`/faturas/${faturaId}/pix`);
    return data?.copia_cola || null;
  }

  async getStatusConexao(codigoCliente) {
    try {
      const data = await this._get(`/clientes/${codigoCliente}/conexao`);
      return {
        online: data?.online === true,
        status: data?.online ? "online" : "offline",
        pppoeUsuario: data?.usuario_pppoe || null,
        ipAtual: data?.ip_atual || null,
        ultimaConexao: data?.ultimo_login || null,
      };
    } catch {
      return { online: false, status: "indisponivel" };
    }
  }

  async desbloquearConfianca(codigoCliente) {
    const data = await this._post(`/clientes/${codigoCliente}/desbloqueio-confianca`, {});
    return {
      sucesso: true,
      mensagem: "Desbloqueio de confiança realizado com sucesso",
      protocolo: data?.protocolo || null,
    };
  }

  async getDadosSuporte() {
    return {
      whatsapp: "(XX) XXXXX-XXXX",
      email: "suporte@provedor.com.br",
      telefone: "0800 XXX XXXX",
    };
  }
}

module.exports = SgpAdapter;
