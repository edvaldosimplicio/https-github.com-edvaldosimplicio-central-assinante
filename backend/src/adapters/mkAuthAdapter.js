const axios = require("axios");
const BaseErpAdapter = require("./baseAdapter");

class MkAuthAdapter extends BaseErpAdapter {
  constructor(config) {
    super(config);
    const baseUrl = config.apiBaseUrl.replace(/\/+$/, "");
    this.client = axios.create({
      baseURL: baseUrl,
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${config.apiToken}`,
      },
      timeout: 30000,
    });
  }

  async getCliente(codigoCliente) {
    const response = await this.client.get(`/clientes/${codigoCliente}`);
    const dados = response.data?.cliente || response.data;
    if (!dados) return null;

    return {
      codigo: dados.id || dados.codigo,
      nome: dados.nome || dados.razao_social,
      cpfCnpj: dados.cpf_cnpj || dados.documento,
      email: dados.email,
      telefone: dados.telefone || dados.celular,
    };
  }

  async getFaturaAberta(codigoCliente) {
    const response = await this.client.get(`/clientes/${codigoCliente}/faturas`, {
      params: { status: "aberto", limite: 1 },
    });
    const faturas = response.data?.faturas || response.data || [];
    if (faturas.length === 0) return null;

    const fatura = faturas[0];
    return {
      id: fatura.id,
      valor: parseFloat(fatura.valor),
      vencimento: fatura.vencimento,
      status: "aberto",
      mesReferencia: fatura.referencia || fatura.competencia,
      linkBoleto: fatura.link_boleto || null,
      pixCopiaECola: fatura.pix_copia_cola || fatura.pix || null,
    };
  }

  async getHistoricoFinanceiro(codigoCliente) {
    const response = await this.client.get(`/clientes/${codigoCliente}/faturas`, {
      params: { limite: 24 },
    });
    const faturas = response.data?.faturas || response.data || [];
    return faturas.map((f) => ({
      id: f.id,
      valor: parseFloat(f.valor),
      vencimento: f.vencimento,
      pagamento: f.data_pagamento || null,
      status: f.status === "pago" ? "pago" : "aberto",
      mesReferencia: f.referencia || f.competencia,
    }));
  }

  async getChavePix(codigoCliente, faturaId) {
    const response = await this.client.get(`/faturas/${faturaId}/pix`);
    return response.data?.pix_copia_cola || response.data?.pix || null;
  }

  async getStatusConexao(codigoCliente) {
    try {
      const response = await this.client.get(`/clientes/${codigoCliente}/conexao`);
      const dados = response.data?.conexao || response.data;
      return {
        online: dados?.online === true || dados?.status === "online",
        status: dados?.online ? "online" : "offline",
        pppoeUsuario: dados?.usuario_pppoe || dados?.login || null,
        ipAtual: dados?.ip_atual || dados?.ip || null,
        ultimaConexao: dados?.ultimo_login || null,
      };
    } catch {
      return { online: false, status: "indisponivel" };
    }
  }

  async desbloquearConfianca(codigoCliente) {
    const response = await this.client.post(`/clientes/${codigoCliente}/desbloquear`, {
      tipo: "confianca",
    });
    return {
      sucesso: true,
      mensagem: "Desbloqueio de confiança realizado com sucesso",
      protocolo: response.data?.protocolo || null,
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

module.exports = MkAuthAdapter;
