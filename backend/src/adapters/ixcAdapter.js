const axios = require("axios");
const BaseErpAdapter = require("./baseAdapter");

class IxcAdapter extends BaseErpAdapter {
  constructor(config) {
    super(config);
    this.client = axios.create({
      baseURL: config.apiBaseUrl.replace(/\/+$/, ""),
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${config.apiToken}`,
        "ixcsoft": "listar",
      },
      timeout: 30000,
    });
  }

  async getCliente(codigoCliente) {
    const response = await this.client.post("/cliente", {
      consulta: { codigo: codigoCliente },
    });
    const dados = response.data?.registros?.[0] || null;
    return dados
      ? {
          codigo: dados.codigo,
          nome: dados.nome_razao,
          cpfCnpj: dados.cnpj_cpf,
          email: dados.email,
          telefone: dados.telefone_celular,
        }
      : null;
  }

  async getFaturaAberta(codigoCliente) {
    const response = await this.client.post("/faturas", {
      consulta: {
        codigo_cliente: codigoCliente,
        status: "aberto",
      },
    });
    const faturas = response.data?.registros || [];
    if (faturas.length === 0) return null;

    const fatura = faturas[0];
    return {
      id: fatura.id,
      valor: parseFloat(fatura.valor_total),
      vencimento: fatura.data_vencimento,
      status: fatura.status,
      mesReferencia: fatura.mes_referencia,
      linkBoleto: fatura.link_boleto || null,
      pixCopiaECola: fatura.pix_copia_cola || null,
    };
  }

  async getHistoricoFinanceiro(codigoCliente) {
    const response = await this.client.post("/faturas", {
      consulta: { codigo_cliente: codigoCliente },
      limite: 24,
      ordenacao: "data_vencimento",
      ordem: "DESC",
    });
    const faturas = response.data?.registros || [];
    return faturas.map((f) => ({
      id: f.id,
      valor: parseFloat(f.valor_total),
      vencimento: f.data_vencimento,
      pagamento: f.data_pagamento || null,
      status: f.status,
      mesReferencia: f.mes_referencia,
    }));
  }

  async getChavePix(codigoCliente, faturaId) {
    const response = await this.client.post("/faturas", {
      consulta: {
        codigo_cliente: codigoCliente,
        id: faturaId,
      },
    });
    const fatura = response.data?.registros?.[0];
    return fatura?.pix_copia_cola || null;
  }

  async getStatusConexao(codigoCliente) {
    try {
      const response = await this.client.post("/radius_usuarios", {
        consulta: { id_cliente: codigoCliente },
      });
      const usuario = response.data?.registros?.[0];
      if (!usuario) return { online: false, status: "sem_conexao" };

      return {
        online: usuario.online === "S",
        status: usuario.online === "S" ? "online" : "offline",
        pppoeUsuario: usuario.usuario,
        ipAtual: usuario.ip_atual || null,
        ultimaConexao: usuario.ultima_conexao || null,
      };
    } catch {
      return { online: false, status: "indisponivel" };
    }
  }

  async desbloquearConfianca(codigoCliente) {
    const response = await this.client.post("/cliente_desbloqueio_confianca", {
      codigo_cliente: codigoCliente,
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

module.exports = IxcAdapter;
