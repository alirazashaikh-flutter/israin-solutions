const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  customer_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  item_id: { type: mongoose.Schema.Types.ObjectId, ref: 'ShopItem', required: true },
  customer_name: { type: String, required: true },
  customer_email: { type: String, required: true },
  customer_phone: { type: String, default: '' },
  item_name: { type: String, required: true },
  price: { type: Number, required: true },
  quantity: { type: Number, default: 1 },
  requirements: { type: String, default: '' },
  status: { type: String, enum: ['pending', 'accepted', 'in_progress', 'delivered', 'cancelled'], default: 'pending' },
  totalAmount: { type: Number, required: true },
  paymentStatus: { type: String, enum: ['unpaid', 'paid'], default: 'unpaid' },
  paymentMethod: { type: String, enum: ['paypal', 'cash'], default: 'cash' },
  paypalOrderId: { type: String, default: '' },
  paypalCaptureId: { type: String, default: '' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Order', orderSchema);
