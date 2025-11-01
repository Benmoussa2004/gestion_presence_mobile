import express from 'express';
import User from '../models/User.js';

const router = express.Router();

router.get('/', async (req, res) => {
  const { role } = req.query;
  const q = role ? { role } : {};
  const users = await User.find(q).limit(200);
  res.json(users.map(u => ({ id: u._id.toString(), name: u.name, email: u.email, role: u.role, uid: u.uid })));
});

router.get('/:id', async (req, res) => {
  const u = await User.findById(req.params.id);
  if (!u) return res.status(404).json({ error: 'Not found' });
  res.json({ id: u._id.toString(), name: u.name, email: u.email, role: u.role, uid: u.uid });
});

router.put('/:id', async (req, res) => {
  const { name, email, role, uid } = req.body;
  const upd = await User.findByIdAndUpdate(req.params.id, { name, email, role, uid }, { new: true, upsert: true });
  res.json({ id: upd._id.toString(), name: upd.name, email: upd.email, role: upd.role, uid: upd.uid });
});

router.post('/by-emails', async (req, res) => {
  const { emails } = req.body;
  if (!Array.isArray(emails)) return res.status(400).json({ error: 'emails[] required' });
  const list = await User.find({ email: { $in: emails } }).limit(200);
  res.json(list.map(u => ({ id: u._id.toString(), name: u.name, email: u.email, role: u.role })));
});

export default router;

