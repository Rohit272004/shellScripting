import "dotenv/config";
import express from "express";
import http from "http";
import cors from "cors";
import mongoose from "mongoose";
import { Server } from "socket.io";
import Metric from "./models/Metric.js";

const app = express();
const server = http.createServer(app);

const PORT = process.env.PORT || 5000;
const AGENT_TOKEN = process.env.AGENT_TOKEN;

app.use(cors());
app.use(express.json());

const io = new Server(server, {
  cors: { origin: "*" }
});

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(error => console.log("MongoDB error:", error));

app.post("/api/metrics", async (req, res) => {
  try {
    const token = req.headers.authorization;

    if (token !== `Bearer ${AGENT_TOKEN}`) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    const data = req.body;

    if (!data.hostname) {
      return res.status(400).json({ message: "Hostname is required" });
    }

    const metric = await Metric.create({
      hostname: data.hostname,
      cpu: data.cpu,
      ram: data.ram,
      disk: data.disk,
      services: data.services || {},
      collectedAt: data.collectedAt || new Date()
    });

    io.emit("monitor-data", metric);

    res.json({ message: "Metric received" });
  } catch (error) {
    console.log("Metric error:", error);
    res.status(500).json({ message: "Could not save metric" });
  }
});

app.get("/api/history", async (req, res) => {
  try {
    const history = await Metric
      .find()
      .sort({ collectedAt: -1 })
      .limit(200);

    res.json(history.reverse());
  } catch (error) {
    res.status(500).json({ message: "Could not get history" });
  }
});

app.get("/api/health", (req, res) => {
  res.json({ status: "running" });
});

io.on("connection", socket => {
  console.log("React client connected");

  socket.on("disconnect", () => {
    console.log("React client disconnected");
  });
});

server.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
