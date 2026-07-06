const { Router } = require("express");
const authController = require("../controllers/authController");

const router = Router();

router.post("/login", (req, res) => authController.login(req, res));

module.exports = router;
