const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const {
    Keypair,
    TransactionBuilder,
    Operation,
    Networks
} = require('diamante-base');
const { Horizon } = require('diamante-sdk-js');

const app = express();
const port = 3001;

app.use(bodyParser.json());
app.use(cors());

app.post('/create-keypair', (req, res) => {
    try {
        console.log('Received request to create keypair');
        const keypair = Keypair.random();
        console.log('Keypair created:', keypair.publicKey(), keypair.secret());
        res.json({
            publicKey: keypair.publicKey(),
            secret: keypair.secret()
        });
    } catch (error) {
        console.error('Error in create-keypair:', error);
        res.status(500).json({ error: error.message });
    }
});

app.post('/fund-account', async (req, res) => {
    try {
        const { publicKey } = req.body;
        console.log(`Received request to fund account ${publicKey}`);
        const fetch = await import('node-fetch').then(mod => mod.default);
        const response = await fetch(`https://friendbot.diamcircle.io/?addr=${publicKey}`);
        if (!response.ok) {
            throw new Error(`Failed to activate account ${publicKey}: ${response.statusText}`);
        }
        const result = await response.json();
        console.log(`Account ${publicKey} activated`, result);
        res.json({ message: `Account ${publicKey} funded successfully` });
    } catch (error) {
        console.error('Error in fund-account:', error);
        res.status(500).json({ error: error.message });
    }
});

app.post('/make-payment', async (req, res) => {
    try {
        const { senderSecret, receiverPublicKey, amount } = req.body;
        console.log(`Received request to make payment from ${senderSecret} to ${receiverPublicKey} with amount ${amount}`);

        const server = new Horizon.Server('https://diamtestnet.diamcircle.io/');
        const senderKeypair = Keypair.fromSecret(senderSecret);
        const senderPublicKey = senderKeypair.publicKey();

        const account = await server.loadAccount(senderPublicKey);
        const transaction = new TransactionBuilder(account, {
            fee: await server.fetchBaseFee(),
            networkPassphrase: Networks.TESTNET,
        })
            .addOperation(Operation.payment({
                destination: receiverPublicKey,
                asset: Asset.native(),
                amount: amount,
            }))
            .setTimeout(30)
            .build();

        transaction.sign(senderKeypair);
        const result = await server.submitTransaction(transaction);
        console.log(`Payment made from ${senderPublicKey} to ${receiverPublicKey} with amount ${amount}`, result);
        res.json({ message: `Payment of ${amount} DIAM made to ${receiverPublicKey} successfully` });
    } catch (error) {
        console.error('Error in make-payment:', error);
        res.status(500).json({ error: error.message });
    }
});

app.post('/manage-data', async (req, res) => {
    try {
        const { senderSecret, key, value } = req.body;
        console.log(`Received request to manage data for key ${key} with value ${value}`);

        const server = new Horizon.Server('https://diamtestnet.diamcircle.io/');
        const senderKeypair = Keypair.fromSecret(senderSecret);
        const senderPublicKey = senderKeypair.publicKey();

        const account = await server.loadAccount(senderPublicKey);
        const transaction = new TransactionBuilder(account, {
            fee: await server.fetchBaseFee(),
            networkPassphrase: Networks.TESTNET,
        })
            .addOperation(Operation.manageData({
                name: key,
                value: value || null,
            }))
            .setTimeout(30)
            .build();

        transaction.sign(senderKeypair);
        const result = await server.submitTransaction(transaction);
        console.log(`Data managed for key ${key} with value ${value}`, result);
        res.json({ message: `Data for key ${key} managed successfully` });
    } catch (error) {
        console.error('Error in manage-data:', error);
        res.status(500).json({ error: error.message });
    }
});

app.post('/set-options', async (req, res) => {
    try {
        const { senderSecret, inflationDest, homeDomain, lowThreshold, medThreshold, highThreshold } = req.body;
        console.log(`Received request to set options with inflationDest: ${inflationDest}, homeDomain: ${homeDomain}, thresholds: ${lowThreshold}, ${medThreshold}, ${highThreshold}`);

        const server = new Horizon.Server('https://diamtestnet.diamcircle.io/');
        const senderKeypair = Keypair.fromSecret(senderSecret);
        const senderPublicKey = senderKeypair.publicKey();

        const account = await server.loadAccount(senderPublicKey);
        const transaction = new TransactionBuilder(account, {
            fee: await server.fetchBaseFee(),
            networkPassphrase: Networks.TESTNET,
        })
            .addOperation(Operation.setOptions({
                inflationDest: inflationDest || undefined,
                homeDomain: homeDomain || undefined,
                lowThreshold: lowThreshold ? parseInt(lowThreshold) : undefined,
                medThreshold: medThreshold ? parseInt(medThreshold) : undefined,
                highThreshold: highThreshold ? parseInt(highThreshold) : undefined,
            }))
            .setTimeout(30)
            .build();

        transaction.sign(senderKeypair);
        const result = await server.submitTransaction(transaction);
        console.log('Options set successfully:', result);
        res.json({ message: 'Options set successfully' });
    } catch (error) {
        console.error('Error in set-options:', error);
        res.status(500).json({ error: error.message });
    }
});

const { v4: uuidv4 } = require('uuid');

// app is already declared above, so no need to redeclare it here
app.use(bodyParser.json());

// In-memory storage for cryptocurrencies (replace with database in production)
let cryptocurrencies = [];

// Middleware for basic authentication
const authenticateUser = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'No authorization header provided' });
  }

  const [type, credentials] = authHeader.split(' ');
  if (type !== 'Basic') {
    return res.status(401).json({ error: 'Invalid authorization type' });
  }

  const [username, password] = Buffer.from(credentials, 'base64').toString().split(':');

  // Replace this with your actual authentication logic
  if (username === 'admin' && password === 'secret') {
    next();
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
};


// Endpoint to add a new cryptocurrency
app.post('/api/cryptocurrencies', authenticateUser, (req, res) => {
  const { name, symbol, initialSupply } = req.body;

  // Validate input
  if (!name || !symbol || !initialSupply) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  if (typeof initialSupply !== 'number' || initialSupply <= 0) {
    return res.status(400).json({ error: 'Initial supply must be a positive number' });
  }

  // Check if cryptocurrency already exists
  if (cryptocurrencies.some(crypto => crypto.symbol === symbol)) {
    return res.status(409).json({ error: 'Cryptocurrency with this symbol already exists' });
  }

  // Create new cryptocurrency
  const newCryptocurrency = {
    id: uuidv4(),
    name,
    symbol,
    supply: initialSupply,
    createdAt: new Date().toISOString()
  };

  // Add to storage
  cryptocurrencies.push(newCryptocurrency);

  res.status(201).json(newCryptocurrency);
});

// Endpoint to get all cryptocurrencies
app.get('/api/cryptocurrencies', authenticateUser, (req, res) => {
  res.json(cryptocurrencies);
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(port, () => {
    console.log(`Diamante backend listening at http://localhost:${port}`);
});