

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
