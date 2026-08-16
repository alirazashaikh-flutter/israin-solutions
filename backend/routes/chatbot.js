const express = require('express');
const router = express.Router();
const { handleMessage } = require('../controllers/chatbotController');
const { auth } = require('../middleware/auth');

router.post('/message', auth, handleMessage);

module.exports = router;
