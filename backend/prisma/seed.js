const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  const provedor = await prisma.provedor.upsert({
    where: { slug: "provedor-exemplo" },
    update: {},
    create: {
      nome: "Provedor Exemplo Telecom",
      slug: "provedor-exemplo",
      logoUrl: "https://raw.githubusercontent.com/netplus-example/logos/main/netplus_white.png",
      primaryColor: "#1A2744",
      secondaryColor: "#2E7D32",
      suporteWhatsapp: "5511999999999",
      m3uUrl: "https://iptv-org.github.io/iptv/countries/br.m3u",
      configuracaoERP: {
        create: {
          tipoERP: "IXC",
          apiBaseUrl: "https://seu-ixc.ixespert.com.br/api",
          apiToken: "SEU_TOKEN_IXC",
        },
      },
    },
  });

  await prisma.usuarioApp.upsert({
    where: {
      provedorId_cpfCnpj: {
        provedorId: provedor.id,
        cpfCnpj: "00000000000",
      },
    },
    update: {},
    create: {
      provedorId: provedor.id,
      cpfCnpj: "00000000000",
      nome: "Cliente Exemplo",
      codigoCliente: "12345",
    },
  });

  console.log("Seed concluído");
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
