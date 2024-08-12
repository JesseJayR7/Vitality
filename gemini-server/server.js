const axios = require('axios');
const express = require('express');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;
const apiKey = process.env.GEMINI_API_KEY;

app.use(bodyParser.json());

app.post('/chat', async (req, res) => {
  const { message, userProfile, metrics } = req.body;
  console.log('Received request:', { message, userProfile, metrics });

  try {
    const response = await axios.post('https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent', {
      contents: [
        {
          role: "user",
          parts: [{ text: message }]
        }
      ]
    }, {
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey
      }
    });

    res.json(response.data);
  } catch (error) {
    console.error('Error:', error.response ? error.response.data : error.message);
    res.status(500).send('Error communicating with Gemini API');
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
