const express = require('express');
const router = express.Router();
const { sendMessage, getMessages, searchMessages } = require('../controllers/messageController');
const { auth } = require('../middleware/auth');

router.post('/', auth, sendMessage);
router.get('/search', auth, searchMessages);
router.get('/:inquiry_id', auth, getMessages);

module.exports = router;
