const Inquiry = require('../models/Inquiry');

exports.createInquiry = async (req, res) => {
  try {
    const { name, email, phone, service_type, message, service_id } = req.body;
    const inquiry = await Inquiry.create({
      customer_id: req.user._id,
      name,
      email,
      phone,
      service_type,
      message,
      service_id
    });
    res.status(201).json(inquiry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getInquiries = async (req, res) => {
  try {
    let filter = {};
    if (req.user.role === 'customer') {
      filter = { customer_id: req.user._id };
    }
    if (req.query.status) {
      filter.status = req.query.status;
    }
    const inquiries = await Inquiry.find(filter)
      .populate('customer_id', 'name email')
      .populate('service_id', 'name category')
      .sort({ createdAt: -1 });
    res.json(inquiries);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getInquiryById = async (req, res) => {
  try {
    const inquiry = await Inquiry.findById(req.params.id)
      .populate('customer_id', 'name email')
      .populate('service_id', 'name category');
    if (!inquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }
    if (req.user.role === 'customer' && inquiry.customer_id._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }
    res.json(inquiry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateInquiry = async (req, res) => {
  try {
    const inquiry = await Inquiry.findByIdAndUpdate(
      req.params.id,
      { status: req.body.status },
      { new: true, runValidators: true }
    );
    if (!inquiry) {
      return res.status(404).json({ message: 'Inquiry not found' });
    }
    res.json(inquiry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
