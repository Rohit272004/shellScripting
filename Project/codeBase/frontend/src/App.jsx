import React, {useEffect, useState} from 'react';
import io from 'socket.io-client';
import './App.css';
import HistoryChart from './components/HistoryChart.jsx';
const socket = io('http://localhost:5000');

function App(){
  const [data,setData] = useState(null);
  useEffect(()=>{ socket.on('monitor-data', setData); },[]);
  if(!data) return <h2 className="loading">Connecting WebSocket...</h2>;

  return(
    <div className="app">
      <h1>🖥️ Complete SOC+SRE Monitor - {data.health.hostname}</h1>
      <p>Live via WebSocket - {data.health.time}</p>

      <div className="grid">
        <div className="card"><h3>CPU</h3><h1>{data.health.cpu}%</h1></div>
        <div className="card"><h3>RAM</h3><h1>{data.health.ram}%</h1></div>
        <div className="card"><h3>DISK</h3><h1>{data.health.disk}%</h1></div>
      </div>

      <HistoryChart />
      <div className="grid2">
        <div className="card"><h2>🔧 Services</h2><pre>{data.logs.services}</pre></div>
        <div className="card"><h2>🐳 Docker</h2><pre>{data.logs.docker}</pre></div>
      </div>

      <div className="card alert"><h2>🚨 Bruteforce IPs (Failed SSH)</h2><pre>{data.logs.bruteforce}</pre></div>
      <div className="card"><h2>🔐 Sudo Usage (Priv Esc)</h2><pre>{data.logs.sudo}</pre></div>
      <div className="card"><h2>🌐 Network & Ports</h2><pre>{data.logs.network}</pre></div>
      
      <div className="card"><h2>📊 Health Log</h2><pre>{data.logs.health}</pre></div>
      <div className="card"><h2>🛡️ Full Security Log</h2><pre>{data.logs.security}</pre></div>
      <div className="card alert"><h2>🚨 Alerts</h2><pre>{data.logs.alerts}</pre></div>
    </div>
  )
}
export default App;