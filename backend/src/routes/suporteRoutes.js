const { Router } = require("express");
const suporteController = require("../controllers/suporteController");
const authMiddleware = require("../middlewares/authMiddleware");
const tenantMiddleware = require("../middlewares/tenantMiddleware");

const router = Router();

router.get("/dados", authMiddleware, tenantMiddleware, (req, res) =>
  suporteController.dados(req, res)
);

module.exports = router;
