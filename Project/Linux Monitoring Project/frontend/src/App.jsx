import { useEffect, useState } from "react";
import { io } from "socket.io-client";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Legend,
  Tooltip
} from "chart.js";
import { Line } from "react-chartjs-2";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Legend,
  Tooltip
);

const BACKEND_URL = "http://localhost:5000";

function App() {
  const [latest, setLatest] = useState(null);
  const [history, setHistory] = useState([]);

  useEffect(() => {
    fetch(`${BACKEND_URL}/api/history`)
      .then(response => response.json())
      .then(data => {
        setHistory(data);
        if (data.length > 0) {
          setLatest(data[data.length - 1]);
        }
      })
      .catch(error => console.log("History error:", error));

    const socket = io(BACKEND_URL);

    socket.on("monitor-data", data => {
      setLatest(data);

      setHistory(oldHistory => {
        const newHistory = [...oldHistory, data];

        if (newHistory.length > 200) {
          newHistory.shift();
        }

        return newHistory;
      });
    });

    return () => socket.disconnect();
  }, []);

  if (!latest) {
    return (
      <div className="page">
        <h1>Linux Server Monitor</h1>
        <p>Waiting for monitoring data...</p>
      </div>
    );
  }

  const chartData = {
    labels: history.map(item =>
      new Date(item.collectedAt).toLocaleTimeString()
    ),
    datasets: [
      { label: "CPU %", data: history.map(item => item.cpu) },
      { label: "RAM %", data: history.map(item => item.ram) },
      { label: "Disk %", data: history.map(item => item.disk) }
    ]
  };

  return (
    <div className="page">
      <h1>Linux Server Monitor</h1>

      <p>Server: <strong>{latest.hostname}</strong></p>

      <div className="cards">
        <div className="card">
          <h2>CPU</h2>
          <p>{latest.cpu}%</p>
        </div>

        <div className="card">
          <h2>RAM</h2>
          <p>{latest.ram}%</p>
        </div>

        <div className="card">
          <h2>Disk</h2>
          <p>{latest.disk}%</p>
        </div>
      </div>

      <div className="card">
        <h2>Services</h2>
        <p>SSH: {latest.services?.ssh}</p>
        <p>Nginx: {latest.services?.nginx}</p>
        <p>Docker: {latest.services?.docker}</p>
      </div>

      <div className="chart">
        <h2>Server Usage History</h2>
        <Line data={chartData} />
      </div>

      <p className="time">
        Last update: {new Date(latest.collectedAt).toLocaleString()}
      </p>
    </div>
  );
}

export default App;
