npx create-react-app my-dashboard --template typescript
cd my-dashboard


npm install @mui/material @emotion/react @emotion/styled react-router-dom @types/react-router-dom http-proxy-middleware


touch src/styles/global.css


body {
  margin: 0;
  font-family: 'Roboto', sans-serif;
}

* {
  box-sizing: border-box;
}


import './styles/global.css';

npm install react@18 react-dom@18 react-scripts typescript @testing-library/react @testing-library/user-event web-vitals --legacy-peer-deps
npm install @mui/material @emotion/react @emotion/styled


npm install react-router-dom @types/react-router-dom



import React from 'react';
import styles from './Navbar.module.css';

const Navbar: React.FC = () => {
  return (
    <div className={styles.navbar}>
      <h1>Kubernetes Dashboard</h1>
    </div>
  );
};

export default Navbar;




.navbar {
  background-color: #1976d2;
  color: white;
  padding: 10px 20px;
  display: flex;
  align-items: center;
  box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.1);
}





/* Reset default browser styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* Body styles */
body {
  font-family: 'Roboto', sans-serif;
  background-color: #f9f9f9;
  color: #333;
}

/* Utility classes */
.text-center {
  text-align: center;
}

.hidden {
  display: none;
}





import React from 'react';
import { Link } from 'react-router-dom';
import styles from './Sidebar.module.css';

const Sidebar: React.FC = () => {
  return (
    <div className={styles.sidebar}>
      <ul>
        <li><Link to="/">Home</Link></li>
        <li><strong>EDCO</strong></li>
        <li><Link to="/edco/test">Test</Link></li>
        <li><Link to="/edco/prep">Prep</Link></li>
        <li><Link to="/edco/prod">Prod</Link></li>
        <li><strong>EDCR</strong></li>
        <li><Link to="/edcr/test">Test</Link></li>
        <li><Link to="/edcr/prep">Prep</Link></li>
        <li><Link to="/edcr/prod">Prod</Link></li>
      </ul>
    </div>
  );
};

export default Sidebar;


.sidebar {
  width: 250px;
  height: 100vh;
  background-color: #f5f5f5;
  position: fixed;
  padding: 20px;
  border-right: 1px solid #ddd;
}

ul {
  list-style: none;
  padding: 0;
}

li {
  margin: 15px 0;
}

a {
  text-decoration: none;
  color: #333;
}

a:hover {
  color: #1976d2;
}



import React from 'react';
import styles from './Home.module.css';

const Home: React.FC = () => {
  return (
    <div className={styles.page}>
      <h1>Welcome to the Kubernetes Dashboard</h1>
      <p>Select a cluster from the sidebar to view details.</p>
    </div>
  );
};

export default Home;


.page {
  margin-left: 250px;
  padding: 20px;
}



import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar/Navbar';
import Sidebar from './components/Sidebar/Sidebar';
import Home from './pages/Home/Home';
import EDCOTest from './pages/EDCO/Test';
import EDCOProd from './pages/EDCO/Prod';
import EDCOPrep from './pages/EDCO/Prep';
import EDCRTest from './pages/EDCR/Test';
import EDCRProd from './pages/EDCR/Prod';
import EDCRPrep from './pages/EDCR/Prep';

const App: React.FC = () => {
  return (
    <Router>
      <Navbar />
      <Sidebar />
      <div style={{ marginLeft: '250px', padding: '20px' }}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/edco/test" element={<EDCOTest />} />
          <Route path="/edco/prep" element={<EDCOPrep />} />
          <Route path="/edco/prod" element={<EDCOProd />} />
          <Route path="/edcr/test" element={<EDCRTest />} />
          <Route path="/edcr/prep" element={<EDCRPrep />} />
          <Route path="/edcr/prod" element={<EDCRProd />} />
        </Routes>
      </div>
    </Router>
  );
};

export default App;



import React from 'react';
import ReactDOM from 'react-dom/client';
import './styles/global.css';
import App from './App';

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

