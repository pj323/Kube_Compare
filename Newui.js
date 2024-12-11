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
import { Drawer, List, ListItem, ListItemText, Typography } from '@mui/material';
import styles from './Sidebar.module.css';

const Sidebar: React.FC = () => {
  return (
    <Drawer
      variant="permanent"
      classes={{ paper: styles.drawerPaper }}
      anchor="left"
    >
      <div className={styles.sidebarHeader}>
        <Typography variant="h6" className={styles.title}>
          Kubernetes Dashboard
        </Typography>
      </div>
      <List>
        <ListItem>
          <ListItemText primary={<strong>Home</strong>} />
        </ListItem>
        <ListItem button component={Link} to="/">
          <ListItemText primary="Home" />
        </ListItem>
        <ListItem>
          <ListItemText primary={<strong>EDCO</strong>} />
        </ListItem>
        <ListItem button component={Link} to="/edco/test">
          <ListItemText primary="Test" />
        </ListItem>
        <ListItem button component={Link} to="/edco/prep">
          <ListItemText primary="Prep" />
        </ListItem>
        <ListItem button component={Link} to="/edco/prod">
          <ListItemText primary="Prod" />
        </ListItem>
        <ListItem>
          <ListItemText primary={<strong>EDCR</strong>} />
        </ListItem>
        <ListItem button component={Link} to="/edcr/test">
          <ListItemText primary="Test" />
        </ListItem>
        <ListItem button component={Link} to="/edcr/prep">
          <ListItemText primary="Prep" />
        </ListItem>
        <ListItem button component={Link} to="/edcr/prod">
          <ListItemText primary="Prod" />
        </ListItem>
      </List>
    </Drawer>
  );
};

export default Sidebar;



.drawerPaper {
  width: 250px;
  background-color: #f5f5f5;
  border-right: 1px solid #ddd;
}

.sidebarHeader {
  padding: 16px;
  text-align: center;
  border-bottom: 1px solid #ddd;
}

.title {
  font-weight: bold;
}

.MuiList-root {
  padding: 0;
}

.MuiListItem-root {
  padding: 8px 16px;
}

.MuiListItemText-primary {
  font-size: 16px;
}

.MuiListItem-root:hover {
  background-color: #e0e0e0;
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

