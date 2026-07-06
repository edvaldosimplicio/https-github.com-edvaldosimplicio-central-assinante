const { getErpAdapter } = require("../utils/erpFactory");

class FinanceiroService {
  async getResumo(provedor, codigoCliente) {
    const adapter = getErpAdapter(provedor.configuracaoERP.tipoERP, provedor.configuracaoERP);

    const faturaAberta = await adapter.getFaturaAberta(codigoCliente);
    const chavePix = faturaAberta?.id
      ? await adapter.getChavePix(codigoCliente, faturaAberta.id)
      : null;

    return {
      faturaAberta: faturaAberta
        ? { ...faturaAberta, pixCopiaECola: chavePix || faturaAberta.pixCopiaECola }
        : null,
    };
  }

  async getHistorico(provedor, codigoCliente) {
    const adapter = getErpAdapter(provedor.configuracaoERP.tipoERP, provedor.configuracaoERP);
    return adapter.getHistoricoFinanceiro(codigoCliente);
  }
}

module.exports = FinanceiroService;
