const ConexaoService = require("../services/conexaoService");

class ConexaoController {
  async status(req, res) {
    try {
      const { codigoCliente } = req;
      const provedor = req.provedor;

      const service = new ConexaoService();
      const result = await service.getStatus(provedor, codigoCliente);

      res.json(result);
    } catch (err) {
      console.error("Erro ao buscar status da conexão:", err);
      res.status(500).json({ error: "Erro ao buscar status da conexão" });
    }
  }

  async desbloquear(req, res) {
    try {
      const { codigoCliente } = req;
      const provedor = req.provedor;

      const service = new ConexaoService();
      const result = await service.desbloquear(provedor, codigoCliente);

      res.json(result);
    } catch (err) {
      console.error("Erro ao desbloquear:", err);
      res.status(500).json({ error: "Erro ao realizar desbloqueio de confiança" });
    }
  }
}

module.exports = new ConexaoController();
