class ProvedorController {
  async config(req, res) {
    try {
      const { slug } = req.params;

      const provedor = await req.prisma.provedor.findUnique({
        where: { slug },
        select: {
          id: true,
          nome: true,
          slug: true,
          logoUrl: true,
          primaryColor: true,
          secondaryColor: true,
          suporteWhatsapp: true,
          m3uUrl: true,
        },
      });

      if (!provedor) {
        return res.status(404).json({ error: "Provedor não encontrado" });
      }

      res.json({
        id: provedor.id,
        nome: provedor.nome,
        slug: provedor.slug,
        logo_url: provedor.logoUrl,
        primary_color: provedor.primaryColor,
        secondary_color: provedor.secondaryColor,
        suporte_whatsapp: provedor.suporteWhatsapp,
        m3u_url: provedor.m3uUrl,
      });
    } catch (err) {
      console.error("Erro ao buscar provedor:", err);
      res.status(500).json({ error: "Erro ao buscar dados do provedor" });
    }
  }
}

module.exports = new ProvedorController();
