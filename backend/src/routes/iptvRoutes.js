const express = require("express");
const router = express.Router();
const iptvController = require("../controllers/iptvController");
const authMiddleware = require("../middlewares/authMiddleware");
const tenantMiddleware = require("../middlewares/tenantMiddleware");

router.get("/canais", authMiddleware, tenantMiddleware, iptvController.getCanais);

module.exports = router;
