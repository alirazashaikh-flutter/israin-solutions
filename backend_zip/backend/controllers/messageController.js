const Message = require('../models/Message');
const Inquiry = require('../models/Inquiry');

exports.sendMessage = async (req, res) => {
  try {
    const { inquiry_id, text } = req.body;

    const inquiry = await Inquiry.findById(inquiry_id);
    if (!inquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }

    if (req.user.role === 'customer' && inquiry.customer_id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const message = await Message.create({
      inquiry_id,
      sender_id: req.user._id,
      text
    });

    if (req.user.role === 'admin' && inquiry.status === 'new') {
      await Inquiry.findByIdAndUpdate(inquiry_id, { status: 'in_discussion' });
    }

    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const messages = await Message.find({ inquiry_id: req.params.inquiry_id })
      .populate('sender_id', 'name role')
      .sort({ createdAt: 1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
