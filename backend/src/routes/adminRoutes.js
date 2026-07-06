const express = require("express");
const router = express.Router();
const adminController = require("../controllers/adminController");

// Admin auth middleware comparing header with JWT_SECRET env var
const adminAuth = (req, res, next) => {
  const adminToken = req.headers["x-admin-token"];
  const expectedSecret = process.env.JWT_SECRET || "sua-chave-secreta-aqui-mude-em-producao";

  if (!adminToken || adminToken !== expectedSecret) {
    return res.status(401).json({ error: "Acesso administrativo não autorizado" });
  }
  next();
};

router.get("/provedores", adminAuth, adminController.listProvedores);
router.post("/provedores", adminAuth, adminController.createProvedor);
router.put("/provedores/:id", adminAuth, adminController.updateProvedor);
router.delete("/provedores/:id", adminAuth, adminController.deleteProvedor);

module.exports = router;
