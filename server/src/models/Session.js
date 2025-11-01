import mongoose from 'mongoose';

const SessionSchema = new mongoose.Schema({
  classId: { type: String, required: true },
  startAt: { type: String, required: true }, // ISO strings for simplicity
  endAt: { type: String, required: true },
  code: { type: String }, // optional QR code or session code
}, { timestamps: true });

export default mongoose.model('Session', SessionSchema);

