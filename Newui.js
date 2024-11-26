npm install react-router-dom @mui/material @emotion/react @emotion/styled


import React from 'react';
import { AppBar, Toolbar, Typography } from '@mui/material';

const Navbar = () => {
  return (
    <AppBar position="static">
      <Toolbar>
        <Typography variant="h6" component="div" style={{ flexGrow: 1 }}>
          Kubernetes Dashboard
        </Typography>
      </Toolbar>
    </AppBar>
  );
};

export default Navbar;


import React from 'react';
import { Link } from 'react-router-dom';
import { Drawer, List, ListItem, ListItemText, Divider } from '@mui/material';

const Sidebar = () => {
  return (
    <Drawer variant="permanent" anchor="left">
      <List>
        <ListItem>
          <ListItemText primary="Clusters" />
        </ListItem>
        <Divider />
        <ListItem>
          <ListItemText primary="EDCO" />
        </ListItem>
        <List component="div" disablePadding>
          <ListItem button component={Link} to="/edco/test">
            <ListItemText primary="Test" />
          </ListItem>
          <ListItem button component={Link} to="/edco/prep">
            <ListItemText primary="Prep" />
          </ListItem>
          <ListItem button component={Link} to="/edco/prod">
            <ListItemText primary="Prod" />
          </ListItem>
        </List>
        <Divider />
        <ListItem>
          <ListItemText primary="EDCR" />
        </ListItem>
        <List component="div" disablePadding>
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
      </List>
    </Drawer>
  );
};

export default Sidebar;



import React from 'react';

const Home = () => {
  return (
    <div style={{ marginLeft: '250px', padding: '20px' }}>
      <h1>Welcome to the Kubernetes Dashboard</h1>
      <p>Select a cluster and environment from the sidebar to view details.</p>
    </div>
  );
};

export default Home;



import React from 'react';

const EDCOTest = () => {
  return (
    <div style={{ marginLeft: '250px', padding: '20px' }}>
      <h1>EDCO - Test Environment</h1>
      <p>Details about the EDCO Test environment will go here.</p>
    </div>
  );
};

export default EDCOTest;




import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Sidebar from './components/Sidebar';
import Home from './components/Home';
import EDCOTest from './pages/EDCOTest';
import EDCOPrep from './pages/EDCOPrep';
import EDCOProd from './pages/EDCOProd';
import EDCRTest from './pages/EDCRTest';
import EDCRPrep from './pages/EDCRPrep';
import EDCRProd from './pages/EDCRProd';

const App = () => {
  return (
    <Router>
      <Navbar />
      <Sidebar />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/edco/test" element={<EDCOTest />} />
        <Route path="/edco/prep" element={<EDCOPrep />} />
        <Route path="/edco/prod" element={<EDCOProd />} />
        <Route path="/edcr/test" element={<EDCRTest />} />
        <Route path="/edcr/prep" element={<EDCRPrep />} />
        <Route path="/edcr/prod" element={<EDCRProd />} />
      </Routes>
    </Router>
  );
};

export default App;





body {
  margin: 0;
  font-family: 'Arial', sans-serif;
}

.App-header {
  background-color: #282c34;
  min-height: 10vh;
  display: flex;
  justify-content: center;
  align-items: center;
  color: white;
}

.drawer {
  width: 250px;
  flex-shrink: 0;
}
