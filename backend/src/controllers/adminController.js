class AdminController {
  // List all providers with their ERP configs
  async listProvedores(req, res) {
    try {
      const provedores = await req.prisma.provedor.findMany({
        include: { configuracaoERP: true },
        orderBy: { createdAt: "desc" },
      });
      res.json(provedores);
    } catch (err) {
      console.error("Erro ao listar provedores:", err);
      res.status(500).json({ error: "Erro ao listar provedores no banco" });
    }
  }

  // Create a new provider and its ERP config
  async createProvedor(req, res) {
    try {
      const {
        nome,
        slug,
        logoUrl,
        primaryColor,
        secondaryColor,
        suporteWhatsapp,
        m3uUrl,
        tipoERP,
        apiBaseUrl,
        apiToken,
        apiSecret,
      } = req.body;

      if (!nome || !slug || !tipoERP || !apiBaseUrl || !apiToken) {
        return res.status(400).json({ error: "Nome, slug, tipoERP, apiBaseUrl e apiToken são obrigatórios" });
      }

      // Check if slug is unique
      const existing = await req.prisma.provedor.findUnique({ where: { slug } });
      if (existing) {
        return res.status(400).json({ error: "Já existe um provedor com este slug" });
      }

      // Create provider and config in a transaction
      const newProvedor = await req.prisma.$transaction(async (tx) => {
        const prov = await tx.provedor.create({
          data: {
            nome,
            slug,
            logoUrl,
            primaryColor: primaryColor || "#1A2744",
            secondaryColor: secondaryColor || "#2E7D32",
            suporteWhatsapp,
            m3uUrl,
          },
        });

        await tx.configuracaoERP.create({
          data: {
            provedorId: prov.id,
            tipoERP,
            apiBaseUrl,
            apiToken,
            apiSecret,
          },
        });

        return tx.provedor.findUnique({
          where: { id: prov.id },
          include: { configuracaoERP: true },
        });
      });

      res.status(201).json(newProvedor);
    } catch (err) {
      console.error("Erro ao criar provedor:", err);
      res.status(500).json({ error: "Erro interno ao criar provedor" });
    }
  }

  // Update provider branding and ERP config
  async updateProvedor(req, res) {
    try {
      const { id } = req.params;
      const {
        nome,
        logoUrl,
        primaryColor,
        secondaryColor,
        suporteWhatsapp,
        m3uUrl,
        ativo,
        tipoERP,
        apiBaseUrl,
        apiToken,
        apiSecret,
      } = req.body;

      // Update in transaction
      const updated = await req.prisma.$transaction(async (tx) => {
        const prov = await tx.provedor.update({
          where: { id },
          data: {
            nome,
            logoUrl,
            primaryColor,
            secondaryColor,
            suporteWhatsapp,
            m3uUrl,
            ativo,
          },
        });

        if (tipoERP && apiBaseUrl && apiToken) {
          await tx.configuracaoERP.upsert({
            where: { provedorId: id },
            update: {
              tipoERP,
              apiBaseUrl,
              apiToken,
              apiSecret,
            },
            create: {
              provedorId: id,
              tipoERP,
              apiBaseUrl,
              apiToken,
              apiSecret,
            },
          });
        }

        return tx.provedor.findUnique({
          where: { id },
          include: { configuracaoERP: true },
        });
      });

      res.json(updated);
    } catch (err) {
      console.error("Erro ao atualizar provedor:", err);
      res.status(500).json({ error: "Erro interno ao atualizar provedor" });
    }
  }

  // Delete provider
  async deleteProvedor(req, res) {
    try {
      const { id } = req.params;
      await req.prisma.provedor.delete({ where: { id } });
      res.json({ success: true, message: "Provedor deletado com sucesso" });
    } catch (err) {
      console.error("Erro ao deletar provedor:", err);
      res.status(500).json({ error: "Erro ao deletar provedor" });
    }
  }
}

module.exports = new AdminController();
