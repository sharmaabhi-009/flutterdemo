import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttConsumer extends StatefulWidget {
  const MqttConsumer({super.key});

  @override
  State<MqttConsumer> createState() => _MqttConsumerState();
}

class _MqttConsumerState extends State<MqttConsumer> {
  late MqttServerClient client;
  final String topic = 'stocks/price';
  List<Map<String, dynamic>> stockData = [];

  @override
  void initState() {
    super.initState();
    setupMqttClient();
    connectAndSubscribe();
  }

  void setupMqttClient() {
    flutter_client_id = new DateTime.now().microsecondsSinceEpoch;
    client = MqttServerClient.withPort(
      'mr-connection-vbx6wbdxa41.messaging.solace.cloud',
      flutter_client_id,
      8883,
    );
    client.secure = true;
    client.setProtocolV311();
    client.keepAlivePeriod = 30;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.logging(on: false);
    client.onBadCertificate = (dynamic certificate) => true;
  }

  Future<void> connectAndSubscribe() async {
    final connMess = MqttConnectMessage()
        .authenticateAs('solace-cloud-client', 'ta8kfrtgke602k998m37m895vt')
        .withClientIdentifier('flutter_client_id')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMess;

    try {
      await client.connect();
      client.subscribe(topic, MqttQos.atMostOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        debugPrint('📥 Received: $payload');
        parseAndSetStockData(payload);
      });
    } catch (e) {
      debugPrint('⛔ Connection error: $e');
      client.disconnect();
    }
  }

  void parseAndSetStockData(String message) {
    try {
      final Map<String, dynamic> jsonData = json.decode(message);
      final List<Map<String, dynamic>> formatted = jsonData.entries
          .map((e) => {'symbol': e.key, 'price': e.value})
          .toList();

      setState(() {
        stockData = formatted;
      });
    } catch (e) {
      debugPrint('⚠️ JSON Parse error: $e');
    }
  }

  void onConnected() => debugPrint('✅ Connected');
  void onDisconnected() => debugPrint('❌ Disconnected');
  void onSubscribed(String topic) =>
      debugPrint('📌 Subscribed to topic: $topic');

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Stock Prices')),
      body: stockData.isEmpty
          ? const Center(child: Text('Waiting for stock data...'))
          : ListView.builder(
              itemCount: stockData.length,
              itemBuilder: (context, index) {
                final stock = stockData[index];
                return ListTile(
                  title: Text(stock['symbol'],
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('\$${stock['price']}'),
                );
              },
            ),
    );
  }
}
