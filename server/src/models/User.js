import mongoose from 'mongoose';

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  passwordHash: { type: String }, // used if local auth
  role: { type: String, enum: ['admin', 'teacher', 'student'], required: true },
  // If using Firebase Auth, store the UID too
  uid: { type: String, index: true },
}, { timestamps: true });

UserSchema.index({ role: 1 });

export default mongoose.model('User', UserSchema);

