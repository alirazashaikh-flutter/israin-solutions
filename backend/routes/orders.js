const express = require('express');
const router = express.Router();
const { createOrder, getOrders, getOrderById, updateOrderStatus, cancelOrder, markOrderPaid } = require('../controllers/orderController');
const { auth, adminOnly } = require('../middleware/auth');

router.post('/', auth, createOrder);
router.get('/', auth, getOrders);
router.get('/:id', auth, getOrderById);
router.put('/:id/status', auth, adminOnly, updateOrderStatus);
router.put('/:id/pay', auth, markOrderPaid);
router.put('/:id/cancel', auth, cancelOrder);

module.exports = router;
