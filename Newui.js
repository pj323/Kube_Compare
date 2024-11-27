

.navbar {
  background-color: #1976d2;
  color: white;
  padding: 10px 20px;
  display: flex;
  align-items: center;
}

.navbarTitle {
  font-size: 20px;
  font-weight: bold;
}

import React from 'react';
import styles from './Navbar.module.css';

const Navbar = () => {
  return (
    <div className={styles.navbar}>
      <span className={styles.navbarTitle}>Kubernetes Dashboard</span>
    </div>
  );
};

export default Navbar;



.sidebar {
  width: 250px;
  background-color: #f5f5f5;
  height: 100vh;
  border-right: 1px solid #ddd;
  position: fixed;
}

.list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.listItem {
  padding: 10px 20px;
  cursor: pointer;
  color: #333;
  text-decoration: none;
  display: block;
}

.listItem:hover {
  background-color: #e0e0e0;
}

.listHeader {
  font-weight: bold;
  padding: 10px 20px;
  color: #555;
}

.divider {
  border-top: 1px solid #ddd;
  margin: 10px 0;
}



import React from 'react';
import { Link } from 'react-router-dom';
import styles from './Sidebar.module.css';

const Sidebar = () => {
  return (
    <div className={styles.sidebar}>
      <div className={styles.listHeader}>Clusters</div>
      <hr className={styles.divider} />
      <div className={styles.listHeader}>EDCO</div>
      <ul className={styles.list}>
        <li>
          <Link to="/edco/test" className={styles.listItem}>Test</Link>
        </li>
        <li>
          <Link to="/edco/prep" className={styles.listItem}>Prep</Link>
        </li>
        <li>
          <Link to="/edco/prod" className={styles.listItem}>Prod</Link>
        </li>
      </ul>
      <hr className={styles.divider} />
      <div className={styles.listHeader}>EDCR</div>
      <ul className={styles.list}>
        <li>
          <Link to="/edcr/test" className={styles.listItem}>Test</Link>
        </li>
        <li>
          <Link to="/edcr/prep" className={styles.listItem}>Prep</Link>
        </li>
        <li>
          <Link to="/edcr/prod" className={styles.listItem}>Prod</Link>
        </li>
      </ul>
    </div>
  );
};

export default Sidebar;





.homeContainer {
  margin-left: 250px; /* Offset for the sidebar */
  padding: 20px;
}

.homeTitle {
  font-size: 24px;
  font-weight: bold;
  color: #333;
}

.homeDescription {
  font-size: 16px;
  color: #555;
}




import React from 'react';
import styles from './Home.module.css';

const Home = () => {
  return (
    <div className={styles.homeContainer}>
      <h1 className={styles.homeTitle}>Welcome to the Kubernetes Dashboard</h1>
      <p className={styles.homeDescription}>
        Select a cluster and environment from the sidebar to view details.
      </p>
    </div>
  );
};

export default Home;




.pageContainer {
  margin-left: 250px; /* Offset for the sidebar */
  padding: 20px;
}

.pageTitle {
  font-size: 24px;
  font-weight: bold;
  color: #333;
}

.pageDescription {
  font-size: 16px;
  color: #555;
}
import React from 'react';
import styles from './EDCOTest.module.css';

const EDCOTest = () => {
  return (
    <div className={styles.pageContainer}>
      <h1 className={styles.pageTitle}>EDCO - Test Environment</h1>
      <p className={styles.pageDescription}>
        Details about the EDCO Test environment will go here.
      </p>
    </div>
  );
};

export default EDCOTest;






import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar/Navbar';
import Sidebar from './components/Sidebar/Sidebar';
import Home from './components/Home/Home';
import EDCOTest from './pages/EDCOTest/EDCOTest';
import EDCOPrep from './pages/EDCOPrep/EDCOPrep';
import EDCOProd from './pages/EDCOProd/EDCOProd';
import EDCRTest from './pages/EDCRTest/EDCRTest';
import EDCRPrep from './pages/EDCRPrep/EDCRPrep';
import EDCRProd from './pages/EDCRProd/EDCRProd';

const App = () => {
  return (
    <Router>
      <div style={{ display: 'flex', height: '100vh' }}>
        <Sidebar />
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
          <Navbar />
          <div style={{ flex: 1 }}>
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
        </div>
      </div>
    </Router>
  );
};

export default App;





import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);



body {
  margin: 0;
  font-family: 'Arial', sans-serif;
}

