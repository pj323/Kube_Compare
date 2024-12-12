import React, { useState } from 'react';
import { AppBar, Toolbar, IconButton, Typography } from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import HomeIcon from '@mui/icons-material/Home';
import Sidebar from '../Sidebar/Sidebar';
import styles from './Navbar.module.css';

const Navbar: React.FC = () => {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  return (
    <>
      <AppBar position="fixed" className={styles.navbar}>
        <Toolbar>
          {/* Hamburger Menu */}
          <IconButton edge="start" color="inherit" onClick={toggleSidebar}>
            <MenuIcon />
          </IconButton>

          {/* Home Button */}
          <IconButton edge="start" color="inherit" href="/">
            <HomeIcon />
          </IconButton>

          {/* Title */}
          <Typography variant="h6" sx={{ flexGrow: 1 }}>
            Kubernetes Dashboard
          </Typography>
        </Toolbar>
      </AppBar>

      {/* Sidebar */}
      <Sidebar open={isSidebarOpen} onClose={toggleSidebar} />
    </>
  );
};

export default Navbar;


.navbar {
  background-color: #d32f2f; /* Red color for Navbar */
}


import React from 'react';
import { Drawer, List, ListItem, ListItemButton, ListItemText, Typography } from '@mui/material';
import { Link } from 'react-router-dom';
import styles from './Sidebar.module.css';

interface SidebarProps {
  open: boolean;
  onClose: () => void;
}

const Sidebar: React.FC<SidebarProps> = ({ open, onClose }) => {
  return (
    <Drawer anchor="left" open={open} onClose={onClose}>
      <div className={styles.sidebar}>
        {/* Sidebar Header */}
        <Typography variant="h6" className={styles.title}>
          Clusters
        </Typography>

        {/* Sidebar Options */}
        <List>
          <ListItem>
            <ListItemText primary={<strong>EDCO</strong>} />
          </ListItem>
          <ListItem>
            <ListItemButton component={Link} to="/edco/test">
              <ListItemText primary="Test" />
            </ListItemButton>
          </ListItem>
          <ListItem>
            <ListItemButton component={Link} to="/edco/prep">
              <ListItemText primary="Prep" />
            </ListItemButton>
          </ListItem>
          <ListItem>
            <ListItemButton component={Link} to="/edco/prod">
              <ListItemText primary="Prod" />
            </ListItemButton>
          </ListItem>
          <ListItem>
            <ListItemText primary={<strong>EDCR</strong>} />
          </ListItem>
          <ListItem>
            <ListItemButton component={Link} to="/edcr/test">
              <ListItemText primary="Test" />
            </ListItemButton>
          </ListItem>
          <ListItem>
            <ListItemButton component={Link} to="/edcr/prep">
              <ListItemText primary="Prep" />
            </ListItemButton>
          </ListItem>
          <ListItem>
            <ListItemButton component={Link} to="/edcr/prod">
              <ListItemText primary="Prod" />
            </ListItemButton>
          </ListItem>
        </List>
      </div>
    </Drawer>
  );
};

export default Sidebar;


.sidebar {
  width: 250px;
  padding: 16px;
}

.title {
  font-weight: bold;
  margin-bottom: 16px;
}



import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar/Navbar';
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
      <div style={{ marginTop: '64px', padding: '20px' }}>
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



/* Global Reset */
body {
  margin: 0;
  padding: 0;
  font-family: 'Roboto', sans-serif;
}

/* Main Content Area */
main {
  margin-top: 64px; /* Adjust for the fixed navbar */
  padding: 20px;
}

/* Responsive Adjustments */
@media (max-width: 600px) {
  main {
    margin-top: 56px;
  }
}
