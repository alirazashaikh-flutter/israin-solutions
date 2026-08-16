const dotenv = require('dotenv');
dotenv.config();

const CLIENT_ID = process.env.PAYPAL_CLIENT_ID;
const SECRET = process.env.PAYPAL_SECRET;
const MODE = process.env.PAYPAL_MODE || 'sandbox';

const BASE_URL = MODE === 'live'
  ? 'https://api-m.paypal.com'
  : 'https://api-m.sandbox.paypal.com';

let cachedToken = null;
let tokenExpiry = 0;

async function getAccessToken() {
  if (cachedToken && Date.now() < tokenExpiry) return cachedToken;

  const auth = Buffer.from(`${CLIENT_ID}:${SECRET}`).toString('base64');
  const response = await fetch(`${BASE_URL}/v1/oauth2/token`, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${auth}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'grant_type=client_credentials',
  });

  if (!response.ok) throw new Error(`PayPal token error: ${response.status}`);

  const data = await response.json();
  cachedToken = data.access_token;
  tokenExpiry = Date.now() + (data.expires_in - 60) * 1000;
  return cachedToken;
}

exports.createOrder = async ({ total, currency = 'USD', description = 'Israin Solutions Order' }) => {
  const token = await getAccessToken();
  const port = process.env.PORT || 5000;
  const host = process.env.PAYPAL_PUBLIC_URL || `http://localhost:${port}`;
  const response = await fetch(`${BASE_URL}/v2/checkout/orders`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      intent: 'CAPTURE',
      purchase_units: [
        {
          amount: {
            currency_code: currency,
            value: total.toFixed(2),
          },
          description,
        },
      ],
      application_context: {
        brand_name: 'Israin Solutions',
        user_action: 'PAY_NOW',
        return_url: `${host}/api/paypal/return`,
        cancel_url: `${host}/api/paypal/cancel`,
      },
    }),
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(`PayPal create order error: ${JSON.stringify(err)}`);
  }

  return response.json();
};

exports.captureOrder = async (orderId) => {
  const token = await getAccessToken();
  const response = await fetch(`${BASE_URL}/v2/checkout/orders/${orderId}/capture`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    const err = await response.json();
    throw new Error(`PayPal capture error: ${JSON.stringify(err)}`);
  }

  return response.json();
};
