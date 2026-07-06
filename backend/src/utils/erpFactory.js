const IxcAdapter = require("../adapters/ixcAdapter");
const SgpAdapter = require("../adapters/sgpAdapter");

function getErpAdapter(tipoERP, config) {
  switch (tipoERP.toUpperCase()) {
    case "IXC":
      return new IxcAdapter(config);
    case "SGP":
      return new SgpAdapter(config);
    default:
      throw new Error(`ERP não suportado: ${tipoERP}`);
  }
}

module.exports = { getErpAdapter };
