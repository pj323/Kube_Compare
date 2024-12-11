import React from 'react';
import { Link } from 'react-router-dom';
import {
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemText,
  Typography,
} from '@mui/material';
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
        <ListItem disablePadding>
          <ListItemButton component={Link} to="/">
            <ListItemText primary="Home" />
          </ListItemButton>
        </ListItem>
        <ListItem>
          <ListItemText primary={<strong>EDCO</strong>} />
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton component={Link} to="/edco/test">
            <ListItemText primary="Test" />
          </ListItemButton>
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton component={Link} to="/edco/prep">
            <ListItemText primary="Prep" />
          </ListItemButton>
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton component={Link} to="/edco/prod">
            <ListItemText primary="Prod" />
          </ListItemButton>
        </ListItem>
        <ListItem>
          <ListItemText primary={<strong>EDCR</strong>} />
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton component={Link} to="/edcr/test">
            <ListItemText primary="Test" />
          </ListItemButton>
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton component={Link} to="/edcr/prep">
            <ListItemText primary="Prep" />
          </ListItemButton>
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton component={Link} to="/edcr/prod">
            <ListItemText primary="Prod" />
          </ListItemButton>
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

.MuiListItemButton-root:hover {
  background-color: #e0e0e0;
}




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
  justify-content: space-between;
  position: fixed;
  width: calc(100% - 250px); /* Subtract the sidebar width */
  z-index: 1000;
  top: 0;
  left: 250px;
  box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.1);
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
      <div style={{ display: 'flex' }}>
        <Sidebar />
        <div style={{ flexGrow: 1, marginTop: '64px' }}>
          <Navbar />
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
        </div>
      </div>
    </Router>
  );
};

export default App;
