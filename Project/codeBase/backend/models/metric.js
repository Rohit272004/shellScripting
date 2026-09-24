import { Schema, model } from 'mongoose';
const MetricSchema = new Schema({
  cpu: Number,
  ram: Number,
  disk: Number,
  timestamp: { type: Date, default: Date.now }
});
MetricSchema.index({ timestamp: 1 }, { expireAfterSeconds: 604800 }); // auto delete 7 days
export default model('Metric', MetricSchema);