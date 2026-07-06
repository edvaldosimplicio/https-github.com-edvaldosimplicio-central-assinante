const FinanceiroService = require("../services/financeiroService");

class FinanceiroController {
  async resumo(req, res) {
    try {
      const { codigoCliente } = req;
      const provedor = req.provedor;

      const service = new FinanceiroService();
      const result = await service.getResumo(provedor, codigoCliente);

      res.json(result);
    } catch (err) {
      console.error("Erro ao buscar resumo financeiro:", err);
      res.status(500).json({ error: "Erro ao buscar dados financeiros" });
    }
  }

  async historico(req, res) {
    try {
      const { codigoCliente } = req;
      const provedor = req.provedor;

      const service = new FinanceiroService();
      const result = await service.getHistorico(provedor, codigoCliente);

      res.json({ faturas: result });
    } catch (err) {
      console.error("Erro ao buscar histórico:", err);
      res.status(500).json({ error: "Erro ao buscar histórico financeiro" });
    }
  }
}

module.exports = new FinanceiroController();
