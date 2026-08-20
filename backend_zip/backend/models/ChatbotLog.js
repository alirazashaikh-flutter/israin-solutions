const mongoose = require('mongoose');

const chatbotLogSchema = new mongoose.Schema({
  inquiry_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Inquiry', required: true },
  customer_query: { type: String, required: true },
  bot_response: { type: String, required: true },
  escalated: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ChatbotLog', chatbotLogSchema);
