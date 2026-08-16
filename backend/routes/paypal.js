const express = require('express');
const router = express.Router();
const { createPayment, capturePayment, paymentReturn, paymentCancel } = require('../controllers/paypalController');
const { auth } = require('../middleware/auth');

router.get('/return', paymentReturn);
router.get('/cancel', paymentCancel);
router.post('/create-order', auth, createPayment);
router.post('/capture-order', auth, capturePayment);

module.exports = router;
