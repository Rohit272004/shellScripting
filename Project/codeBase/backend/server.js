require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const { exec } = require('child_process');
const mongoose = require('mongoose');
const Metric = require('./models/metric');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });
app.use(require('cors')());
mongoose.connect(process.env.MONGO_URI).then(()=>console.log("Mongo Connected"));

function run(cmd){ return new Promise(res=>{ exec(cmd,{timeout:3000},(e,out)=>res(out||"No data")); }); }

async function getLiveData(){
  const cpu = parseInt(await run("top -bn1 | grep 'Cpu' | awk '{print $2}' | cut -d'.' -f1"))||0;
  const ram = parseInt(await run("free | awk '/Mem/{printf \"%.0f\", $3/$2*100}'"))||0;
  const disk = parseInt(await run("df / | awk 'NR==2{print $5}' | tr -d '%'"))||0;
  await new Metric({cpu,ram,disk}).save();

  return {
    health: {cpu,ram,disk,time:new Date().toLocaleString(), hostname: require('os').hostname()},
    logs: {
      health: await run("tail -10 /var/log/server-monitor/health.log"),
      alerts: await run("tail -10 /var/log/server-monitor/alert.log || echo 'No alerts'"),
      security: await run("tail -80 /var/log/server-monitor/security.log"),
      // NEW 5 LIVE
      sudo: await run("journalctl --since '1 hour ago' | grep sudo | tail -10"),
      network: await run("ss -tuln | head -15; echo '---ESTAB---'; ss -tunap | grep ESTAB | head -10"),
      bruteforce: await run("journalctl _COMM=sshd --since '1 hour ago' | grep Failed | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -5 || echo 'No failed SSH'"),
      docker: await run("docker ps -a 2>&1 | head -10 || echo 'No docker'"),
      services: await run("systemctl is-active sshd nginx docker 2>&1")
    }
  };
}

app.get('/api/history', async (req,res)=>{
  const data = await Metric.find().sort({timestamp:1}).limit(200);
  res.json(data);
});

io.on('connection', (socket)=>{
  const interval = setInterval(async ()=>{
    const data = await getLiveData();
    socket.emit('monitor-data', data);
  }, 2000);
  socket.on('disconnect', ()=> clearInterval(interval));
});

server.listen(5000, ()=> console.log('Backend Live on 5000 - Broadcasting every 2s'));