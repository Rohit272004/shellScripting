import "dotenv/config";

import express from "express";
import http from "http";
import os from "os";
import cors from "cors";
import { Server } from "socket.io";
import { exec } from "child_process";
import mongoose from "mongoose";

import Metric from "./models/metric.js";


const app = express();

const server = http.createServer(app);

const io = new Server(server, {
    cors: {
        origin: "*"
    }
});

app.use(cors());


// ============================
// MongoDB
// ============================

mongoose
    .connect(process.env.MONGO_URI)
    .then(() => console.log("MongoDB connected"))
    .catch(error => console.log("MongoDB error:", error));


// ============================
// Run Linux command
// ============================

function runCommand(command) {

    return new Promise(resolve => {

        exec(command, { timeout: 3000 }, (error, output) => {

            if (error) {
                resolve("No data");
                return;
            }

            resolve(output.trim() || "No data");
        });

    });
}


// ============================
// CPU
// ============================

async function getCPU() {

    const result = await runCommand(
        "top -bn1 | grep 'Cpu' | awk '{print $2}'"
    );

    return parseInt(result) || 0;
}


// ============================
// RAM
// ============================

async function getRAM() {

    const result = await runCommand(
        "free | awk '/Mem/ {printf \"%.0f\", $3/$2*100}'"
    );

    return parseInt(result) || 0;
}


// ============================
// Disk
// ============================

async function getDisk() {

    const result = await runCommand(
        "df / | awk 'NR==2 {print $5}' | tr -d '%'"
    );

    return parseInt(result) || 0;
}


// ============================
// Logs
// ============================

async function getLogs() {

    return {

        health: await runCommand(
            "tail -10 /var/log/server-monitor/health.log"
        ),

        alerts: await runCommand(
            "tail -10 /var/log/server-monitor/alert.log"
        ),

        security: await runCommand(
            "tail -80 /var/log/server-monitor/security.log"
        ),

        sudo: await runCommand(
            "journalctl --since '1 hour ago' | grep sudo | tail -10"
        ),

        network: await runCommand(
            "ss -tuln | head -15"
        ),

        bruteForce: await runCommand(
            "journalctl _COMM=sshd --since '1 hour ago' | grep Failed | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -5"
        ),

        docker: await runCommand(
            "docker ps -a"
        ),

        services: await runCommand(
            "systemctl is-active sshd nginx docker"
        )

    };
}


// ============================
// Get all monitoring data
// ============================

async function getMonitoringData() {

    const cpu = await getCPU();

    const ram = await getRAM();

    const disk = await getDisk();


    // Save metrics
    await Metric.create({
        cpu,
        ram,
        disk
    });


    const logs = await getLogs();


    return {

        health: {
            cpu,
            ram,
            disk,
            time: new Date().toLocaleString(),
            hostname: os.hostname()
        },

        logs

    };
}


// ============================
// History API
// ============================

app.get("/api/history", async (req, res) => {

    const history = await Metric
        .find()
        .sort({ timestamp: 1 })
        .limit(200);

    res.json(history);
});


// ============================
// Socket.IO
// ============================

io.on("connection", socket => {

    console.log("Frontend connected");


    const timer = setInterval(async () => {

        const data = await getMonitoringData();

        socket.emit("monitor-data", data);

    }, 2000);


    socket.on("disconnect", () => {

        console.log("Frontend disconnected");

        clearInterval(timer);

    });

});


// ============================
// Start server
// ============================

server.listen(5000, () => {

    console.log("Backend running on port 5000");

});