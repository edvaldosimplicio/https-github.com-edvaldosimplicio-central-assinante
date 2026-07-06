const AuthService = require("../services/authService");

class AuthController {
  async login(req, res) {
    try {
      const { cpf_cnpj } = req.body;

      if (!cpf_cnpj) {
        return res.status(400).json({ error: "CPF/CNPJ é obrigatório" });
      }

      const authService = new AuthService(req.prisma);
      const result = await authService.login(cpf_cnpj);

      if (!result.sucesso) {
        return res.status(401).json({ error: result.erro });
      }

      res.json(result);
    } catch (err) {
      console.error("Erro no login:", err);
      res.status(500).json({ error: "Erro interno ao autenticar" });
    }
  }
}

module.exports = new AuthController();
