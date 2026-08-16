const express = require('express');
const router = express.Router();
const { getShopItems, getShopItemById, createShopItem, updateShopItem, deleteShopItem } = require('../controllers/shopController');
const { auth, adminOnly } = require('../middleware/auth');

router.get('/', getShopItems);
router.get('/:id', getShopItemById);
router.post('/', auth, adminOnly, createShopItem);
router.put('/:id', auth, adminOnly, updateShopItem);
router.delete('/:id', auth, adminOnly, deleteShopItem);

module.exports = router;
