const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

app.use(express.static(path.join(__dirname, 'public'))); 
const upload = multer({
  dest: 'uploads/',  
  limits: { fileSize: 50 * 1024 * 1024 },  
});

let models = [];

app.get('/api/getModels', (req, res) => {
  res.json(models);
});

app.post('/api/createModel', upload.single('file'), (req, res) => {
  const { name, description, price, seller } = req.body;  
  const file = req.file;

  if (!name || !description || !price || !file || !seller) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const newModel = {
    name,
    description,
    price,
    seller, 
    filePath: path.join(__dirname, 'uploads', file.filename),
  };

  models.push(newModel);
  res.status(201).json(newModel);  
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
