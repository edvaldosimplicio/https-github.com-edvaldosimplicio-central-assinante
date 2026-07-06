const { getErpAdapter } = require("../utils/erpFactory");

class ConexaoService {
  async getStatus(provedor, codigoCliente) {
    const adapter = getErpAdapter(provedor.configuracaoERP.tipoERP, provedor.configuracaoERP);
    return adapter.getStatusConexao(codigoCliente);
  }

  async desbloquear(provedor, codigoCliente) {
    const adapter = getErpAdapter(provedor.configuracaoERP.tipoERP, provedor.configuracaoERP);
    return adapter.desbloquearConfianca(codigoCliente);
  }
}

module.exports = ConexaoService;
