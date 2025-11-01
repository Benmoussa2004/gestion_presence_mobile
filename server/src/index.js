import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/gestion_presence';

// DB connect
mongoose.connect(MONGO_URI).then(() => {
  console.log('MongoDB connected');
}).catch((e) => {
  console.error('MongoDB connection error', e);
  process.exit(1);
});

// Models
import './models/User.js';
import './models/Class.js';
import './models/Session.js';
import './models/Attendance.js';

// Routes
import authRoutes from './routes/auth.js';
import usersRoutes from './routes/users.js';
import classesRoutes from './routes/classes.js';
import sessionsRoutes from './routes/sessions.js';
import attendanceRoutes from './routes/attendances.js';

app.get('/health', (req, res) => res.json({ ok: true }));
app.use('/auth', authRoutes);
app.use('/users', usersRoutes);
app.use('/classes', classesRoutes);
app.use('/sessions', sessionsRoutes);
app.use('/attendances', attendanceRoutes);

app.listen(PORT, () => console.log(`API running on :${PORT}`));

