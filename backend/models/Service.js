const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  category: { type: String, enum: ['ai_dev', 'digital_marketing'], required: true },
  description: { type: String, required: true },
  price: { type: Number, required: true },
  timeline: { type: String, required: true },
  useCases: [{ type: String }],
  requestCount: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Service', serviceSchema);
