const mongoose = require('mongoose');

const shopItemSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  category: { type: String, enum: ['graphics', 'web', 'marketing', 'ai', 'animation'], required: true },
  description: { type: String, required: true },
  price: { type: Number, required: true },
  deliveryTime: { type: String, required: true },
  features: [{ type: String }],
  image: { type: String, default: '' },
  active: { type: Boolean, default: true },
  orderCount: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ShopItem', shopItemSchema);
