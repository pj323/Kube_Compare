

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
