const http = require('http');
const { Server } = require('socket.io');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const dotenv = require('dotenv');
const connectDB = require('./config/db');
const { setSocketIO } = require('./socket');
const rateLimit = require('express-rate-limit');
const Message = require('./models/Message');
const Inquiry = require('./models/Inquiry');
const User = require('./models/User');
const Notification = require('./models/Notification');

dotenv.config();

connectDB();

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

setSocketIO(io);

app.use((req, res, next) => {
  console.log('>>> INCOMING REQUEST:', req.method, req.originalUrl);
  next();
});

app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
  crossOriginEmbedderPolicy: false,
}));
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(morgan('dev'));
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: { message: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: { message: 'Too many auth attempts, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', apiLimiter);
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/signup', authLimiter);
app.use('/api/auth/forgot-password', authLimiter);

app.use('/api/auth', require('./routes/auth'));
app.use('/api/services', require('./routes/services'));
app.use('/api/inquiries', require('./routes/inquiries'));
app.use('/api/messages', require('./routes/messages'));
app.use('/api/chatbot', require('./routes/chatbot'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/upload', require('./routes/upload'));
app.use('/api/ratings', require('./routes/ratings'));
app.use('/api/shop', require('./routes/shop'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/paypal', require('./routes/paypal'));

app.get('/', (req, res) => {
  res.json({ message: 'Israin Solutions API is running' });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  if (err.message && err.message.includes('Only PDF')) {
    return res.status(400).json({ message: err.message });
  }
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({ message: 'File size exceeds 10MB limit' });
  }
  res.status(500).json({ message: 'Something went wrong!' });
});

const connectedUsers = new Map();

io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);

  socket.on('user_online', (userId) => {
    connectedUsers.set(userId, socket.id);
    io.emit('online_users', Array.from(connectedUsers.keys()));
  });

  socket.on('join_inquiry', (inquiryId) => {
    socket.join(inquiryId);
    console.log(`Socket ${socket.id} joined inquiry: ${inquiryId}`);
  });

  socket.on('send_message', async (data) => {
    try {
      const { inquiry_id, text, sender_id, attachments } = data;

      const message = await Message.create({
        inquiry_id,
        sender_id,
        text,
        attachments: attachments || [],
      });

      const populated = await Message.findById(message._id)
        .populate('sender_id', 'name role');

      io.to(inquiry_id).emit('receive_message', populated);

      const inquiry = await Inquiry.findById(inquiry_id);
      if (!inquiry) return;

      if (populated.sender_id.role === 'admin' && inquiry.status === 'new') {
        await Inquiry.findByIdAndUpdate(inquiry_id, { status: 'in_discussion' });
      }

      if (populated.sender_id.role === 'admin') {
        await Notification.create({
          user_id: inquiry.customer_id,
          title: 'New Reply',
          body: text.length > 80 ? text.substring(0, 80) + '...' : text,
          type: 'message',
        });
      }

      if (populated.sender_id.role === 'customer') {
        const admins = await User.find({ role: 'admin' }).select('_id');
        for (const admin of admins) {
          await Notification.create({
            user_id: admin._id,
            title: 'New Customer Reply',
            body: text.length > 80 ? text.substring(0, 80) + '...' : text,
            type: 'message',
          });
        }
      }
    } catch (error) {
      console.error('Socket send_message error:', error);
    }
  });

  socket.on('mark_read', async (data) => {
    try {
      const { inquiry_id, reader_id } = data;
      await Message.updateMany(
        { inquiry_id, sender_id: { $ne: reader_id }, read: false },
        { $set: { read: true } }
      );
      io.to(inquiry_id).emit('messages_read', { inquiry_id, reader_id });
    } catch (error) {
      console.error('Socket mark_read error:', error);
    }
  });

  socket.on('typing', (data) => {
    const { inquiry_id, user_name } = data;
    socket.to(inquiry_id).emit('user_typing', { inquiry_id, user_name });
  });

  socket.on('stop_typing', (data) => {
    const { inquiry_id } = data;
    socket.to(inquiry_id).emit('user_stop_typing', { inquiry_id });
  });

  socket.on('disconnect', () => {
    for (const [userId, socketId] of connectedUsers.entries()) {
      if (socketId === socket.id) {
        connectedUsers.delete(userId);
        break;
      }
    }
    io.emit('online_users', Array.from(connectedUsers.keys()));
    console.log('Client disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});