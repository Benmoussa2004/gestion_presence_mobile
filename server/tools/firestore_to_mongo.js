import dotenv from 'dotenv';
import mongoose from 'mongoose';
import admin from 'firebase-admin';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
if (!serviceAccountPath) {
  console.error('Set GOOGLE_APPLICATION_CREDENTIALS to your Firebase service account JSON path');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccountPath),
});

const db = admin.firestore();

// Mongo models
import '../src/models/User.js';
import '../src/models/Class.js';
import '../src/models/Session.js';
import '../src/models/Attendance.js';
import mongoosePkg from 'mongoose';
const { model } = mongoosePkg;

await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/gestion_presence');

async function migrateCollection(fsName, mongoModelName, mapFn) {
  console.log(`Migrating ${fsName} -> ${mongoModelName}`);
  const Model = model(mongoModelName);
  const snap = await db.collection(fsName).get();
  let count = 0;
  for (const doc of snap.docs) {
    const src = { id: doc.id, ...doc.data() };
    const dst = mapFn(src);
    await Model.findByIdAndUpdate(dst._id || undefined, dst, { upsert: true });
    count++;
  }
  console.log(`  ${count} docs migrated.`);
}

await migrateCollection('users', 'User', (u) => ({
  _id: u.id,
  name: u.name || '',
  email: u.email || '',
  role: u.role || 'student',
  uid: u.id,
}));

await migrateCollection('classes', 'Class', (c) => ({
  _id: c.id,
  name: c.name || '',
  teacherId: c.teacherId || '',
  studentIds: c.studentIds || [],
  createdAt: c.createdAt ? new Date(c.createdAt) : new Date(),
}));

await migrateCollection('sessions', 'Session', (s) => ({
  _id: s.id,
  classId: s.classId || '',
  startAt: s.startAt || '',
  endAt: s.endAt || '',
  code: s.code || '',
}));

await migrateCollection('attendances', 'Attendance', (a) => ({
  _id: a.id,
  sessionId: a.sessionId || '',
  studentId: a.studentId || '',
  status: a.status || 'absent',
  markedAt: a.markedAt || new Date().toISOString(),
}));

console.log('Migration complete.');
await mongoose.disconnect();
process.exit(0);

