const AuthService = require("../services/authService");

class AuthController {
  async login(req, res) {
    try {
      const { cpf_cnpj, cpf, provider_slug, provedor_slug } = req.body;
      const cleanCpf = (cpf_cnpj || cpf || "").replace(/\D/g, "");

      if (!cleanCpf) {
        return res.status(400).json({ error: "CPF/CNPJ é obrigatório" });
      }

      const authService = new AuthService(req.prisma);
      const result = await authService.login(cleanCpf, provider_slug || provedor_slug);

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
