const { getErpAdapter } = require("../utils/erpFactory");

class SuporteController {
  async dados(req, res) {
    try {
      const provedor = req.provedor;
      const adapter = getErpAdapter(provedor.configuracaoERP.tipoERP, provedor.configuracaoERP);
      const dados = await adapter.getDadosSuporte();

      res.json(dados);
    } catch (err) {
      console.error("Erro ao buscar dados de suporte:", err);
      res.status(500).json({ error: "Erro ao buscar dados de suporte" });
    }
  }
}

module.exports = new SuporteController();
