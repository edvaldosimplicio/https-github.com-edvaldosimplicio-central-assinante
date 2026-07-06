const IxcAdapter = require("../adapters/ixcAdapter");
const SgpAdapter = require("../adapters/sgpAdapter");
const MkAuthAdapter = require("../adapters/mkAuthAdapter");

function getErpAdapter(tipoERP, config) {
  switch (tipoERP.toUpperCase()) {
    case "IXC":
      return new IxcAdapter(config);
    case "SGP":
      return new SgpAdapter(config);
    case "MKAUTH":
      return new MkAuthAdapter(config);
    default:
      throw new Error(`ERP não suportado: ${tipoERP}`);
  }
}

module.exports = { getErpAdapter };
