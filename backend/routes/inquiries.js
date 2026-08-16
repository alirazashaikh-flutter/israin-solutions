const express = require('express');
const router = express.Router();
const {
  createInquiry,
  getInquiries,
  getInquiryById,
  updateInquiry,
  getOrCreateChatInquiry,
  cancelInquiry,
  resolveInquiry,
  getNotes,
  addNote
} = require('../controllers/inquiryController');
const { auth } = require('../middleware/auth');

router.post('/', auth, createInquiry);
router.get('/', auth, getInquiries);
router.get('/chat', auth, getOrCreateChatInquiry);
router.get('/:id', auth, getInquiryById);
router.get('/:id/notes', auth, getNotes);
router.put('/:id', auth, updateInquiry);
router.put('/:id/cancel', auth, cancelInquiry);
router.put('/:id/resolve', auth, resolveInquiry);
router.post('/:id/notes', auth, addNote);

module.exports = router;
