import React, { useEffect, useState } from 'react';
import { Line } from 'react-chartjs-2';
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend } from 'chart.js';
ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend);

export default function HistoryChart() {
  const [history, setHistory] = useState([]);
  useEffect(() => {
    const load = () => fetch('http://localhost:5000/api/history').then(r=>r.json()).then(setHistory);
    load();
    const id = setInterval(load, 10000);
    return () => clearInterval(id);
  }, []);

  const chartData = {
    labels: history.map(h => new Date(h.timestamp).toLocaleTimeString()),
    datasets: [
      { label: 'CPU', data: history.map(h=>h.cpu), borderColor: '#38bdf8' },
      { label: 'RAM', data: history.map(h=>h.ram), borderColor: '#4ade80' },
      { label: 'DISK', data: history.map(h=>h.disk), borderColor: '#facc15' }
    ]
  };
  return <div className="card"><h2>📈 24H History (from MongoDB)</h2><Line data={chartData} /></div>;
}