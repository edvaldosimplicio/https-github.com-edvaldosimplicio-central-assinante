const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const path = require("path");

const authRoutes = require("./routes/authRoutes");
const financeiroRoutes = require("./routes/financeiroRoutes");
const conexaoRoutes = require("./routes/conexaoRoutes");
const suporteRoutes = require("./routes/suporteRoutes");
const provedorRoutes = require("./routes/provedorRoutes");
const iptvRoutes = require("./routes/iptvRoutes");
const adminRoutes = require("./routes/adminRoutes");

const { PrismaClient } = require("@prisma/client");

const app = express();
const prisma = new PrismaClient();

// app.use(helmet());
app.use(cors());
app.use(express.json());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { error: "Muitas requisições, tente novamente mais tarde" },
});
app.use("/api/", limiter);

app.use((req, res, next) => {
  req.prisma = prisma;
  next();
});

app.use("/api/auth", authRoutes);
app.use("/api/financeiro", financeiroRoutes);
app.use("/api/conexao", conexaoRoutes);
app.use("/api/suporte", suporteRoutes);
app.use("/api/provedor", provedorRoutes);
app.use("/api/iptv", iptvRoutes);
app.use("/api/admin", adminRoutes);

// Serve admin panel
app.use("/admin", express.static(path.join(__dirname, "../../admin")));

app.get("/api/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// Redirect root to admin
app.get("/", (req, res) => {
  res.redirect("/admin");
});

app.use((err, req, res, next) => {
  console.error("Erro não tratado:", err);
  res.status(500).json({ error: "Erro interno do servidor" });
});

module.exports = app;
