import { useState } from 'react';

function App() {
  const [count, setCount] = useState(0);

  return (
    <div style={{ padding: '2rem', fontFamily: 'system-ui, sans-serif' }}>
      <h1>{{PROJECT_NAME}}</h1>
      <p>Welcome to your new web app!</p>
      
      <div style={{ marginTop: '1rem' }}>
        <button 
          onClick={() => setCount(c => c + 1)}
          style={{
            padding: '0.5rem 1rem',
            fontSize: '1rem',
            cursor: 'pointer',
            borderRadius: '4px',
            border: '1px solid #ccc',
            background: '#f0f0f0'
          }}
        >
          Count: {count}
        </button>
      </div>

      <footer style={{ marginTop: '2rem', color: '#666', fontSize: '0.875rem' }}>
        <p>Built with Vite + React + TypeScript</p>
        <p>Created: {{DATE}} | Author: {{AUTHOR}}</p>
      </footer>
    </div>
  );
}

export default App;
