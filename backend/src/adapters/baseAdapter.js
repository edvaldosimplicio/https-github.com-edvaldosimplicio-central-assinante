class BaseErpAdapter {
  constructor(config) {
    this.apiBaseUrl = config.apiBaseUrl;
    this.apiToken = config.apiToken;
    this.apiSecret = config.apiSecret;
  }

  async getCliente(codigoCliente) {
    throw new Error("Método getCliente deve ser implementado");
  }

  async getFaturaAberta(codigoCliente) {
    throw new Error("Método getFaturaAberta deve ser implementado");
  }

  async getHistoricoFinanceiro(codigoCliente) {
    throw new Error("Método getHistoricoFinanceiro deve ser implementado");
  }

  async getChavePix(codigoCliente, faturaId) {
    throw new Error("Método getChavePix deve ser implementado");
  }

  async getStatusConexao(codigoCliente) {
    throw new Error("Método getStatusConexao deve ser implementado");
  }

  async desbloquearConfianca(codigoCliente) {
    throw new Error("Método desbloquearConfianca deve ser implementado");
  }

  async getDadosSuporte() {
    throw new Error("Método getDadosSuporte deve ser implementado");
  }
}

module.exports = BaseErpAdapter;
