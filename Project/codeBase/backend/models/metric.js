const mongoose = require('mongoose');
const MetricSchema = new mongoose.Schema({
  cpu: Number,
  ram: Number,
  disk: Number,
  timestamp: { type: Date, default: Date.now }
});
MetricSchema.index({ timestamp: 1 }, { expireAfterSeconds: 604800 }); // auto delete 7 days
module.exports = mongoose.model('Metric', MetricSchema);