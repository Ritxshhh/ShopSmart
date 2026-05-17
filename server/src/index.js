require('dotenv').config();
const app = require('./app');

const PORT = process.env.PORT || 5001;

app.init().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
});
