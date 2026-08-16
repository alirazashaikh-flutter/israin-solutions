const Order = require('../models/Order');
const ShopItem = require('../models/ShopItem');
const { sendEmail } = require('../services/emailService');

exports.createOrder = async (req, res) => {
  try {
    const { item_id, customer_name, customer_email, customer_phone, quantity, requirements, paymentMethod, paypalOrderId, paypalCaptureId } = req.body;
    const item = await ShopItem.findById(item_id);
    if (!item) return res.status(404).json({ message: 'Item not found' });

    const qty = quantity || 1;
    const totalAmount = item.price * qty;

    const order = await Order.create({
      customer_id: req.user._id,
      item_id,
      customer_name: customer_name || req.user.name || 'Customer',
      customer_email: customer_email || req.user.email || '',
      customer_phone: customer_phone || '',
      item_name: item.name,
      price: item.price,
      quantity: qty,
      requirements: requirements || '',
      totalAmount,
      paymentMethod: paymentMethod === 'paypal' ? 'paypal' : 'cash',
      paymentStatus: paymentMethod === 'paypal' ? 'paid' : 'unpaid',
      paypalOrderId: paypalOrderId || '',
      paypalCaptureId: paypalCaptureId || '',
    });

    await ShopItem.findByIdAndUpdate(item_id, { $inc: { orderCount: 1 } });

    try {
      const html = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #19ADE4;">New Order Received</h2>
          <table style="width: 100%; border-collapse: collapse;">
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Customer:</td><td style="padding: 8px 0;">${customer_name}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Email:</td><td style="padding: 8px 0;">${customer_email}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Phone:</td><td style="padding: 8px 0;">${customer_phone || 'N/A'}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Service:</td><td style="padding: 8px 0;">${item.name}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Price:</td><td style="padding: 8px 0;">$${item.price}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Quantity:</td><td style="padding: 8px 0;">${qty}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Total:</td><td style="padding: 8px 0;">$${totalAmount}</td></tr>
            <tr><td style="padding: 8px 0; font-weight: bold; color: #555;">Requirements:</td><td style="padding: 8px 0;">${requirements || 'None'}</td></tr>
          </table>
        </div>
      `;
      await sendEmail({ to: 'arappsstudio10@gmail.com', subject: `New Order - ${item.name}`, html });
    } catch (e) {
      console.error('Order email failed:', e.message);
    }

    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getOrders = async (req, res) => {
  try {
    let filter = {};
    if (req.user.role === 'customer') {
      filter = { customer_id: req.user._id };
    }
    if (req.query.status) {
      filter.status = req.query.status;
    }
    const orders = await Order.find(filter)
      .populate('item_id', 'name category image')
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id).populate('item_id', 'name category image');
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateOrderStatus = async (req, res) => {
  try {
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status: req.body.status },
      { new: true }
    );
    if (!order) return res.status(404).json({ message: 'Order not found' });
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.markOrderPaid = async (req, res) => {
  try {
    const existing = await Order.findById(req.params.id);
    if (!existing) return res.status(404).json({ message: 'Order not found' });

    const order = await Order.findByIdAndUpdate(
      req.params.id,
      {
        paymentStatus: 'paid',
        paymentMethod: 'paypal',
        paypalOrderId: req.body.paypalOrderId || existing.paypalOrderId || '',
        paypalCaptureId: req.body.paypalCaptureId || existing.paypalCaptureId || '',
      },
      { new: true }
    );
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.cancelOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Order not found' });
    if (req.user.role === 'customer' && order.customer_id.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }
    order.status = 'cancelled';
    await order.save();
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
