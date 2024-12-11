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

