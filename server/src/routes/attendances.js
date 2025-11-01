import express from 'express';
import Attendance from '../models/Attendance.js';

const router = express.Router();

router.get('/', async (req, res) => {
  const { sessionId } = req.query;
  const q = sessionId ? { sessionId } : {};
  const list = await Attendance.find(q).limit(500);
  res.json(list.map(a => ({ id: a._id.toString(), sessionId: a.sessionId, studentId: a.studentId, status: a.status, markedAt: a.markedAt })));
});

router.post('/', async (req, res) => {
  const { sessionId, studentId, status, markedAt } = req.body;
  const a = await Attendance.create({ sessionId, studentId, status, markedAt });
  res.status(201).json({ id: a._id.toString() });
});

router.post('/upsert', async (req, res) => {
  const { sessionId, studentId, status, markedAt } = req.body;
  const a = await Attendance.findOneAndUpdate(
    { sessionId, studentId },
    { status, markedAt },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );
  res.json({ id: a._id.toString(), sessionId: a.sessionId, studentId: a.studentId, status: a.status, markedAt: a.markedAt });
});

export default router;

