async function tenantMiddleware(req, res, next) {
  const provedorId = req.provedorId || req.headers["x-provedor-id"] || req.query.provedor_id;

  if (!provedorId) {
    return res.status(400).json({ error: "Identificador do provedor não informado" });
  }

  try {
    const provedor = await req.prisma.provedor.findUnique({
      where: { id: provedorId },
      include: { configuracaoERP: true },
    });

    if (!provedor || !provedor.ativo) {
      return res.status(404).json({ error: "Provedor não encontrado ou inativo" });
    }

    if (!provedor.configuracaoERP) {
      return res.status(500).json({ error: "Provedor sem configuração de ERP" });
    }

    req.provedor = provedor;
    req.erpConfig = provedor.configuracaoERP;
    next();
  } catch (err) {
    console.error("Erro no tenantMiddleware:", err);
    res.status(500).json({ error: "Erro ao identificar provedor" });
  }
}

module.exports = tenantMiddleware;
