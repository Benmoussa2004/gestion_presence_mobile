import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';

const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret';

// Local signup (optional if not using Firebase Auth)
router.post('/signup', async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    if (!email || !password || !role) return res.status(400).json({ error: 'Missing fields' });
    const exists = await User.findOne({ email });
    if (exists) return res.status(409).json({ error: 'Email already used' });
    const passwordHash = await bcrypt.hash(password, 10);
    const u = await User.create({ name, email, passwordHash, role });
    res.status(201).json({ id: u._id.toString(), name: u.name, email: u.email, role: u.role });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Local login -> JWT
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const u = await User.findOne({ email });
    if (!u) return res.status(401).json({ error: 'Invalid credentials' });
    if (!u.passwordHash) return res.status(400).json({ error: 'User has no local password' });
    const ok = await bcrypt.compare(password, u.passwordHash);
    if (!ok) return res.status(401).json({ error: 'Invalid credentials' });
    const token = jwt.sign({ sub: u._id.toString(), role: u.role }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: { id: u._id.toString(), name: u.name, email: u.email, role: u.role } });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

export default router;

