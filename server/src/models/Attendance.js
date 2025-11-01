import mongoose from 'mongoose';

const AttendanceSchema = new mongoose.Schema({
  sessionId: { type: String, required: true, index: true },
  studentId: { type: String, required: true, index: true },
  status: { type: String, enum: ['present', 'absent'], required: true },
  markedAt: { type: String, required: true },
}, { timestamps: true });

AttendanceSchema.index({ sessionId: 1, studentId: 1 }, { unique: true });

export default mongoose.model('Attendance', AttendanceSchema);

