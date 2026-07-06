const jwt = require("jsonwebtoken");
const { getErpAdapter } = require("../utils/erpFactory");

class AuthService {
  constructor(prisma) {
    this.prisma = prisma;
  }

  async login(cpfCnpj, provedorSlug) {
    const cleanCpf = cpfCnpj.replace(/\D/g, "");

    const query = {
      where: {
        cpfCnpj: cleanCpf,
        ativo: true,
      },
      include: {
        provedor: {
          include: { configuracaoERP: true },
        },
      },
    };

    if (provedorSlug) {
      query.where.provedor = { slug: provedorSlug };
    }

    const usuario = await this.prisma.usuarioApp.findFirst(query);

    if (!usuario) {
      return { sucesso: false, erro: "Cliente não cadastrado ou inativo" };
    }

    const provedor = usuario.provedor;
    if (!provedor || !provedor.ativo) {
      return { sucesso: false, erro: "Provedor associado está inativo" };
    }

    if (!provedor.configuracaoERP) {
      return { sucesso: false, erro: "Configuração do ERP do provedor não localizada" };
    }

    let dadosCliente;
    try {
      const adapter = getErpAdapter(provedor.configuracaoERP.tipoERP, provedor.configuracaoERP);
      dadosCliente = await adapter.getCliente(usuario.codigoCliente);
    } catch (e) {
      console.warn("Erro ao conectar ao ERP, usando dados de fallback locais:", e.message);
      dadosCliente = {
        nome: usuario.nome || "Cliente Exemplo",
        cpfCnpj: usuario.cpfCnpj,
        email: "cliente.exemplo@provedor.com.br",
      };
    }

    if (!dadosCliente) {
      return { sucesso: false, erro: "Cliente não localizado no ERP" };
    }

    const token = jwt.sign(
      {
        usuarioId: usuario.id,
        provedorId: provedor.id,
        codigoCliente: usuario.codigoCliente,
        provedorSlug: provedor.slug,
      },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    await this.prisma.tokenSessao.create({
      data: {
        provedorId: provedor.id,
        usuarioId: usuario.id,
        token,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    return {
      sucesso: true,
      token,
      usuario: {
        nome: dadosCliente.nome,
        cpfCnpj: dadosCliente.cpfCnpj,
        email: dadosCliente.email,
      },
      provedor: {
        id: provedor.id,
        nome: provedor.nome,
        slug: provedor.slug,
        logo_url: provedor.logoUrl,
        primary_color: provedor.primaryColor,
        secondary_color: provedor.secondaryColor,
        suporte_whatsapp: provedor.suporteWhatsapp,
        m3u_url: provedor.m3uUrl,
      },
    };
  }
}

module.exports = AuthService;
