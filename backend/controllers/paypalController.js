const paypal = require('../services/paypalService');

const PAGE = (title, message) => `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${title}</title>
  <style>
    body { font-family: -apple-system, Segoe UI, Roboto, Arial, sans-serif; background: #f5f7fa; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
    .card { background: #fff; padding: 40px; border-radius: 16px; box-shadow: 0 8px 30px rgba(0,0,0,0.08); text-align: center; max-width: 420px; margin: 20px; }
    .icon { width: 56px; height: 56px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 16px; }
    .ok { background: #e6f7ee; }
    .warn { background: #fff3e0; }
    h1 { font-size: 20px; margin: 0 0 8px; color: #1a1a2e; }
    p { color: #5b6472; line-height: 1.5; margin: 0; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon ${title === 'Payment Successful' ? 'ok' : 'warn'}">${title === 'Payment Successful' ? '&#10003;' : '&#10007;'}</div>
    <h1>${title}</h1>
    <p>${message}</p>
  </div>
</body>
</html>`;

exports.paymentReturn = (req, res) => {
  res.send(PAGE('Payment Successful', 'Your PayPal payment was completed. You can now close this page and return to the app to confirm your order.'));
};

exports.paymentCancel = (req, res) => {
  res.send(PAGE('Payment Cancelled', 'Your PayPal payment was cancelled. No charge was made. You can close this page and continue shopping in the app.'));
};

exports.createPayment = async (req, res) => {
  try {
    const { total, description } = req.body;
    if (!total || total <= 0) return res.status(400).json({ message: 'Invalid amount' });

    const order = await paypal.createOrder({
      total,
      description: description || `Order from ${req.user.name || 'Customer'}`,
    });

    const approvalLink = order.links.find((l) => l.rel === 'approve');
    res.json({
      paypalOrderId: order.id,
      approvalUrl: approvalLink ? approvalLink.href : null,
      order,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.capturePayment = async (req, res) => {
  try {
    const { paypalOrderId, simulate } = req.body;

    if (simulate) {
      return res.json({
        success: true,
        status: 'COMPLETED',
        simulated: true,
        paypalOrderId: paypalOrderId || `SIM-${Date.now()}`,
        captureId: `SIM-CAP-${Date.now()}`,
        amount: req.body.amount || 0,
      });
    }

    if (!paypalOrderId) return res.status(400).json({ message: 'paypalOrderId required' });

    const result = await paypal.captureOrder(paypalOrderId);

    const status = (result.status || '').toUpperCase();
    if (status !== 'COMPLETED') {
      return res.status(400).json({ message: `Payment not completed: ${status}` });
    }

    const purchase = result.purchase_units && result.purchase_units[0];
    const capture = purchase && purchase.payments && purchase.payments.captures && purchase.payments.captures[0];
    const paypalInfo = capture
      ? {
          paypalOrderId: result.id,
          captureId: capture.id,
          amount: capture.amount && capture.amount.value,
          currency: capture.amount && capture.amount.currency_code,
          payerEmail: result.payer && result.payer.email_address,
        }
      : { paypalOrderId: result.id };

    res.json({ success: true, status, ...paypalInfo });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
