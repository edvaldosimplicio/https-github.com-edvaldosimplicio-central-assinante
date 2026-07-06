const { Router } = require("express");
const conexaoController = require("../controllers/conexaoController");
const authMiddleware = require("../middlewares/authMiddleware");
const tenantMiddleware = require("../middlewares/tenantMiddleware");

const router = Router();

router.get("/status", authMiddleware, tenantMiddleware, (req, res) =>
  conexaoController.status(req, res)
);

router.post("/desbloquear", authMiddleware, tenantMiddleware, (req, res) =>
  conexaoController.desbloquear(req, res)
);

module.exports = router;
