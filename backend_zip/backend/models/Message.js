const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  inquiry_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Inquiry', required: true },
  sender_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  text: { type: String, default: '' },
  attachments: [{
    filename: String,
    originalName: String,
    mimetype: String,
    size: Number,
    url: String
  }],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Message', messageSchema);
