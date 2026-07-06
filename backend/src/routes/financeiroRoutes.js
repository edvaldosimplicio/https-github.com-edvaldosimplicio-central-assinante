const { Router } = require("express");
const financeiroController = require("../controllers/financeiroController");
const authMiddleware = require("../middlewares/authMiddleware");
const tenantMiddleware = require("../middlewares/tenantMiddleware");

const router = Router();

router.get("/resumo", authMiddleware, tenantMiddleware, (req, res) =>
  financeiroController.resumo(req, res)
);

router.get("/historico", authMiddleware, tenantMiddleware, (req, res) =>
  financeiroController.historico(req, res)
);

module.exports = router;
