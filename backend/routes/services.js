const express = require('express');
const router = express.Router();
const {
  getAllServices,
  getServiceById,
  createService,
  updateService,
  deleteService
} = require('../controllers/serviceController');
const { auth, adminOnly } = require('../middleware/auth');

router.get('/', getAllServices);
router.get('/:id', getServiceById);
router.post('/', auth, adminOnly, createService);
router.put('/:id', auth, adminOnly, updateService);
router.delete('/:id', auth, adminOnly, deleteService);

module.exports = router;
