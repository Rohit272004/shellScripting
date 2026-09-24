import mongoose from "mongoose";

const metricSchema = new mongoose.Schema({
  hostname: { type: String, required: true },
  cpu: { type: Number, required: true },
  ram: { type: Number, required: true },
  disk: { type: Number, required: true },
  services: {
    ssh: String,
    nginx: String,
    docker: String
  },
  collectedAt: { type: Date, default: Date.now }
});

export default mongoose.model("Metric", metricSchema);
