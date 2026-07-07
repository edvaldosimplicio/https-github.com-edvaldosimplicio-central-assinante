const axios = require("axios");
const { PrismaClient } = require("@prisma/client");
const crypto = require("crypto");

const BASE = "https://redemeganet.sgp.net.br";
const USERNAME = "EDVALDOSIMPLICIO";
const PASSWORD = "91239032";

let jar = {};

function updateJar(h) {
  if (!h) return;
  const list = Array.isArray(h) ? h : [h];
  for (const c of list) {
    const m = c.match(/^([^=]+)=([^;]+)/);
    if (m) jar[m[1]] = m[2];
  }
}

function cookieStr() {
  return Object.entries(jar).map(([k, v]) => `${k}=${v}`).join("; ");
}

async function ensureLogin() {
  if (jar.sessionid) return;
  const r1 = await axios.get(`${BASE}/accounts/login/`, {
    headers: { "User-Agent": "Mozilla/5.0" },
  });
  updateJar(r1.headers["set-cookie"]);
  const csrf = r1.data.match(/csrfmiddlewaretoken.*?value=['"]([^'"]+)['"]/)?.[1];
  const r2 = await axios.post(`${BASE}/accounts/login/`,
    new URLSearchParams({ username: USERNAME, password: PASSWORD, csrfmiddlewaretoken: csrf, next: "/admin/" }).toString(),
    { maxRedirects: 0, validateStatus: s => s < 400 || s === 302,
      headers: { "Content-Type": "application/x-www-form-urlencoded", "Cookie": cookieStr(),
        "Referer": `${BASE}/accounts/login/`, "User-Agent": "Mozilla/5.0" },
    });
  updateJar(r2.headers["set-cookie"]);
  if (r2.status === 302 && r2.headers.location) {
    const r3 = await axios.get(`${BASE}${r2.headers.location}`, {
      headers: { "Cookie": cookieStr(), "User-Agent": "Mozilla/5.0" },
    });
    updateJar(r3.headers["set-cookie"]);
  }
  if (!jar.sessionid) throw new Error("Login failed");
}

async function get(path) {
  await ensureLogin();
  const r = await axios.get(`${BASE}${path}`, {
    maxRedirects: 5,
    headers: { "Cookie": cookieStr(), "User-Agent": "Mozilla/5.0" },
  });
  updateJar(r.headers["set-cookie"]);
  return r.data;
}

async function main() {
  const prisma = new PrismaClient();
  await prisma.$connect();

  const provedor = await prisma.provedor.findFirst({ where: { slug: "redemeganet" } });
  if (!provedor) {
    console.log("Provider redemeganet not found");
    return;
  }
  console.log("Provider ID:", provedor.id);

  const searchTerms = "abcdefghijklmnopqrstuvwxyz0123456789".split("");
  const uniqueClients = new Map();

  console.log("Fetching autocomplete results...");
  for (const term of searchTerms) {
    try {
      const data = await get(`/public/autocomplete/ClienteAutocomplete/?tconsulta=nome&term=${term}`);
      const list = typeof data === "string" && data.startsWith("[") ? JSON.parse(data) : Array.isArray(data) ? data : [];
      console.log(`Term "${term}": found ${list.length} matches`);
      
      for (const item of list) {
        if (!item.label || !item.id) continue;
        const match = item.label.match(/^([\s\S]+?)\s+-\s+([\d.-]+)\s+-\s+Cliente ID:(\d+)/i);
        if (match) {
          const nome = match[1].trim();
          const rawCpf = match[2].replace(/\D/g, "");
          const id = match[3];
          
          if (rawCpf && rawCpf.length >= 11) {
            uniqueClients.set(rawCpf, { nome, id, cpf: rawCpf });
          }
        }
      }
    } catch (err) {
      console.error(`Error fetching term "${term}":`, err.message);
    }
  }

  console.log(`\nFound ${uniqueClients.size} unique clients to process.`);

  let imported = 0;
  let skipped = 0;

  for (const [cpf, client] of uniqueClients.entries()) {
    try {
      const existing = await prisma.usuarioApp.findFirst({
        where: {
          provedorId: provedor.id,
          cpfCnpj: cpf
        }
      });

      if (existing) {
        skipped++;
        continue;
      }

      await prisma.usuarioApp.create({
        data: {
          id: crypto.randomUUID(),
          provedorId: provedor.id,
          codigoCliente: String(client.id),
          nome: client.nome,
          cpfCnpj: cpf,
          email: "",
          telefone: "",
          ativo: true
        }
      });
      imported++;
      console.log(`Imported: ${client.nome} (${cpf}) - ID ${client.id}`);
    } catch (dbErr) {
      console.error(`Error importing ${client.nome}:`, dbErr.message);
    }
  }

  console.log(`\nImport complete: ${imported} imported, ${skipped} skipped (already existed).`);
  await prisma.$disconnect();
}

main().catch(console.error);
