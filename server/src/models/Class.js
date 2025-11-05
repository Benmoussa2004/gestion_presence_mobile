import mongoose from 'mongoose';

const ClassSchema = new mongoose.Schema({
  name: { type: String, required: true },
  teacherId: { type: String, required: true }, // store user id (uid or mongo _id)
  studentIds: { type: [String], default: [] },
  createdAt: { type: Date, default: Date.now },
}, { timestamps: true });

ClassSchema.index({ teacherId: 1 });
ClassSchema.index({ createdAt: -1 });

export default mongoose.model('Class', ClassSchema);

