const mongoose = require('mongoose');

const inquirySchema = new mongoose.Schema({
  customer_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  service_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Service' },
  name: { type: String, required: true, trim: true },
  email: { type: String, required: true, trim: true },
  phone: { type: String, trim: true },
  service_type: { type: String, enum: ['ai_dev', 'digital_marketing', 'general_chat'], required: true },
  message: { type: String, required: true },
  budget: { type: String, default: '' },
  priority: { type: String, enum: ['urgent', 'standard'], default: 'standard' },
  attachments: [{
    filename: String,
    originalName: String,
    mimetype: String,
    size: Number,
    url: String
  }],
  status: { type: String, enum: ['new', 'in_discussion', 'resolved', 'cancelled'], default: 'new' },
  admin_notes: [{
    text: String,
    admin_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    createdAt: { type: Date, default: Date.now }
  }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Inquiry', inquirySchema);
