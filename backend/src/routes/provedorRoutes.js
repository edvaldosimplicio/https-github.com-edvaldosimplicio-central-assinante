const { Router } = require("express");
const provedorController = require("../controllers/provedorController");

const router = Router();

router.get("/:slug", (req, res) => provedorController.config(req, res));

module.exports = router;
