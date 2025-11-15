import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import dotenv from 'dotenv';
import compression from 'compression';

dotenv.config();

const app = express();
app.use(cors());
app.use(compression());
app.use(express.json());

// ----------------------------
// CONFIG
// ----------------------------
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI 
  || "mongodb+srv://benmoussamohamedamine04_db_user:Benmoussa2004@cluster0.8qdohdr.mongodb.net/gestion_presence?retryWrites=true&w=majority";

// ----------------------------
// DATABASE CONNECTION
// ----------------------------
mongoose.connect(MONGO_URI)
  .then(() => console.log("✔️ MongoDB Atlas connecté"))
  .catch(err => console.error("❌ Erreur connexion MongoDB:", err));

// ----------------------------
// ROUTES
// ----------------------------
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

// ----------------------------
// SERVER CLOUD
// ----------------------------
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Backend en ligne et écoute sur le port ${PORT}`);
});
