# 📈 Stock APP with Solace

[![Node.js Version](https://img.shields.io/badge/Node.js-16%2B-green)](https://nodejs.org/)
[![Solace](https://img.shields.io/badge/Solace-Messaging-00BFFF)](https://solace.com/)
[![Solace PubSub+](https://img.shields.io/badge/Solace%20PubSub%2B-Event%20Broker-0080FF)](https://solace.com/products/event-broker/)
[![Flutter](https://img.shields.io/badge/Flutter-3%2B-02569B)](https://flutter.dev/)
[![MQTT](https://img.shields.io/badge/MQTT-Protocol-FF8200)](https://mqtt.org/)


The Stock App is a live stock tracking application built with Flutter. It allows users to view stock data from different markets (NSE, BSE) in real time, providing information such as stock prices and changes. The app connects to a broker service using MQTT to receive live stock updates. 

---

## 🔧 Tech Stack

- **Frontend:** Flutter
- **Backend:** Dart & Flutter
- **Real-time Messaging:** Socket.IO
- **Messaging Middleware:** Solace PubSub+, MQTT
- **Database:** None (lightweight, in-memory delivery)

---

## 📁 Folder Structure
```bash
stock-app-solace/
│
├── flutter_stock/          # Flutter frontend
│   ├── lib/
│   │   ├── main.dart
│   │   ├── widget/
│   │   |   └── stock_card.dart     # Stock Block
│   │   ├── page/
│   │   |   └── home_page.dart     # Home page Multiple-Stocks
│   │   └── services
│   │       ├── mqtt_service.dart   #  Handel Payload by brocker
│   │       └── mqtt_consumer.dart   # backup module for testing (not being called)
│   ├── .env
│   └── pubspec.yaml
│ 
├── Producer_Auto/                # Auto Produce stock data to their topic
│   ├── .env
│   ├── stockData.js
│   ├── solacePublisher.js
│   └── server.js
├── .gitignore
├── README.md
```
## 🚀 Getting Started

Follow these steps to run the app locally:

### ✅ 1. Clone the Repository

```bash
git clone https://github.com/Tanendra77/Stock-APP---Flutter.git
cd Stock-APP---Flutter
---
```
⚙️ Configuration:
Solace Client Connection Details (Make Sure Both are same)
```env
# Canada Server - admin/admin

# SOLACE_USERNAME=admin
# SOLACE_PASSWORD=admin
# SOLACE_URL=http://mr-connection-6ne3htd4xcm.messaging.solace.cloud:8883
# SOLACE_HOST=mr-connection-6ne3htd4xcm.messaging.solace.cloud



# Mumbai Server UIC acc -> service-1

# SOLACE_URL=wss://mr-connection-m7ckf6qh9f7.messaging.solace.cloud:8883
# SOLACE_VPN=service-1
# SOLACE_HOST=mr-connection-m7ckf6qh9f7.messaging.solace.cloud
# SOLACE_USERNAME=solace-cloud-client
# SOLACE_PASSWORD=gsoaspfqqnoupoo97d0osiufbl


# London Server - admin/admin

SOLACE_USERNAME=admin
SOLACE_PASSWORD=admin
SOLACE_URL=ssl://mr-connection-ycul43t2mik.messaging.solace.cloud:8883
SOLACE_HOST=mr-connection-ycul43t2mik.messaging.solace.cloud

```

✅ 2. Flutter Frontend Setup
📁 Navigate to the Flutter app directory:
```bash
cd flutter_stock
```
📦 Get all the Flutter dependencies:

```bash
flutter pub get

```
▶️ Run the Flutter app:

Make sure your backend server is running before launching the app.

```bash
flutter run
```

ℹ️ If you're running on an emulator or physical device, choose the device when prompted or run with a specific target:

```bash
flutter run -d windows     # For Windows desktop
flutter run -d chrome      # For Web
flutter run -d emulator-5554  # Example for Android emulator
```
---

### 📱 Generating APK

```bash
cd flutter_stock
flutter clean
flutter pub get
flutter build apk
```
It will give the path to the APK like
```
(base) PS flutter_stock> flutter build apk

Running Gradle task 'assembleRelease'...                           92.7s
√ Built build\app\outputs\flutter-apk\app-release.apk (20.6MB)
```

## 🖼️ Topic Subscription and Publishing Flow

![TopicFlow](./assets/TopicFlow.png)

---

📦 Payload Structure

The payload should be sent to the topic, (every payload had a unique payload value but the structure is same for all)

JSON payload example-

```bash
{
  symbol: 'POWERGRID',
  name: 'Power Grid Corp',
  price: 339.18,
  topic: 'Stock/BSE/infra/equities/POWERGRID'
}
```

---
📋 Stocks and Their Topics

NSE Stocks
```bash
SBI: Stock/NSE/bank/equities/SBI

HDFCBANK: Stock/NSE/bank/equities/HDFCBANK

TCS: Stock/NSE/tech/equities/TCS

INFY: Stock/NSE/tech/equities/INFY

ITC: Stock/NSE/consumer/equities/ITC

HINDUNILVR: Stock/NSE/consumer/equities/HINDUNILVR

ASIANPAINT: Stock/NSE/consumer/equities/ASIANPAINT

MARUTI: Stock/NSE/auto/equities/MARUTI

AXISBANK: Stock/NSE/bank/equities/AXISBANK

WIPRO: Stock/NSE/tech/equities/WIPRO
```

BSE Stocks
```bash
RELIANCE: Stock/BSE/energy/equities/RELIANCE

BAJAJ_AUTO: Stock/BSE/auto/equities/BAJAJ_AUTO

LT: Stock/BSE/infra/equities/LT

SUNPHARMA: Stock/BSE/pharma/equities/SUNPHARMA

ONGC: Stock/BSE/energy/equities/ONGC

TITAN: Stock/BSE/consumer/equities/TITAN

POWERGRID: Stock/BSE/infra/equities/POWERGRID

DRREDDY: Stock/BSE/pharma/equities/DRREDDY

HCLTECH: Stock/BSE/tech/equities/HCLTECH

KOTAKBANK: Stock/BSE/bank/equities/KOTAKBANK
```

---

## 📈 Stock Auto Producer (Solace + Node.js)

This Node.js application auto-generates stock prices and publishes updates every 5 seconds to Solace PubSub+ topics using MQTT.

The stocks are from NSE and BSE exchanges, with realistic random price movements (maximum ±15% from the original price).

🚀 How It Works

20 Stocks are preloaded (10 from NSE and 10 from BSE).

Each stock has:

symbol

name

sector

price

exchange (NSE/BSE)

The app publishes to dynamic topics like:
```bash
Stock/NSE/bank/equities/SBI
Stock/BSE/energy/equities/RELIANCE
```
🛠️ Setup Instructions
go to the directry in a new terminal and run
```bash
npm install
node server.js
```
It will run until it's not stopped from the terminal

