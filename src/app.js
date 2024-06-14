const express = require('express');
const app = express();
const port = 80;

app.get('/', (req, res) => {
  res.send('Hello World! after task');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
