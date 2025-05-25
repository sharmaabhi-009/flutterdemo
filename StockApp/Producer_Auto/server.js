const stocks = require('./stockData');
const { connectPublisher, publishStock } = require('./mqttPublisher');
require('dotenv').config();

function updatePrice(stock) {
  const percentageChange = Math.random() * 0.15; // 0% to 15%
  const changeAmount = stock.price * percentageChange;
  const increase = Math.random() < 0.5;

  stock.price = increase ? stock.price + changeAmount : stock.price - changeAmount;
  stock.price = parseFloat(stock.price.toFixed(2));
}

async function startAutoPublishing() {
  try {
    await connectPublisher();

    setInterval(() => {
      stocks.forEach(stock => {
        updatePrice(stock);

        const topic = `Stock/${stock.exchange}/${stock.sector}/equities/${stock.symbol}`;
        const payload = {
          symbol: stock.symbol,
          name: stock.name,
          price: stock.price,
          topic: topic
        };

        publishStock(topic, payload);
      });
    }, process.env.PRODUCTION_SPEED ?? 5000); // Every 5 sec

  } catch (error) {
    console.error('Error starting publisher:', error);
  }
}

startAutoPublishing();
