// mqttPublisher.js
require('dotenv').config();
const mqtt = require('mqtt');

const options = {
  host: process.env.SOLACE_HOST,
  port: 8883,
  protocol: 'mqtts',
  protocolId: 'MQTT',
  protocolVersion: 4, // Use 4 for MQTT 3.1.1
  username: process.env.SOLACE_USERNAME,
  password: process.env.SOLACE_PASSWORD,
  clean: false,//persistent
  reconnectPeriod: 1000,
  // connectTimeout: 10000,
  clientId: 'node_auto_publisher',
  rejectUnauthorized: false,
};

let client = null;

function connectPublisher() {
  return new Promise((resolve, reject) => {
    client = mqtt.connect(options);

    client.on('connect', () => {
      console.log('[Publisher] Connected to Solace MQTT.');
      resolve();
    });

    client.on('error', (err) => {
      console.error('[Publisher] Connection error:', err);
      reject(err);
    });
  });
}

function publishStock(topic, payload) {
  if (!client || !client.connected) {
    console.error('[Publisher] Not connected.');
    return;
  }

  const message = JSON.stringify(payload);

  //P retain = true
  client.publish(topic, message, { qos: 0, retain: true }, (err) => {
    if (err) {
      console.error(`[Publisher] Failed to publish to ${topic}:`, err);
    } else {
      console.log(`[Publisher] Published (retain) to ${topic}:`, payload);
    }
  });
}

module.exports = { connectPublisher, publishStock };
