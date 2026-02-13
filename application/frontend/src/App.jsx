import { useState, useEffect } from "react";
import axios from "axios";

function App() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [newItem, setNewItem] = useState("");

  useEffect(() => {
    fetchItems();
  }, []);

  const fetchItems = async () => {
    try {
      const response = await axios.get("/api/items");
      setItems(response.data);
      setLoading(false);
    } catch (err) {
      setError(err.message);
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!newItem.trim()) return;

    try {
      await axios.post("/api/items", { name: newItem });
      setNewItem("");
      fetchItems(); // Refresh list
    } catch (err) {
      alert("Failed to add item: " + err.message);
    }
  };

  return (
    <div className="container">
      <header className="header">
        <h1>Three-Tier Web App</h1>
        <p>React Frontend + Python Flask Backend + RDS PostgreSQL + Redis</p>
      </header>

      <main className="content">
        <div className="card">
          <h2>Items List</h2>

          <form onSubmit={handleSubmit} className="form">
            <input
              type="text"
              value={newItem}
              onChange={(e) => setNewItem(e.target.value)}
              placeholder="Add new item..."
              className="input"
            />
            <button type="submit" className="button">
              Add
            </button>
          </form>

          {loading && <p>Loading...</p>}
          {error && <p className="error">Error: {error}</p>}

          <ul className="list">
            {items.map((item) => (
              <li key={item.id} className="list-item">
                <span className="item-name">{item.name}</span>
                {item.description && (
                  <span className="item-desc">{item.description}</span>
                )}
              </li>
            ))}
          </ul>
        </div>
      </main>
    </div>
  );
}

export default App;
