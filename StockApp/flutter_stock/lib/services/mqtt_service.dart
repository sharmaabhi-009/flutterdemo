import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../global.dart';

class MqttService extends ChangeNotifier {
  late MqttServerClient client;
  String? _subscribedTopic;
  StreamSubscription? _subscription;

  List<Map<String, dynamic>> get stocks {
    if (_subscribedTopic != null && stockDataByTopic[_subscribedTopic!] != null) {
      debugPrint('🔄 Stock data for topic $_subscribedTopic: ${stockDataByTopic[_subscribedTopic!]}');
      return stockDataByTopic[_subscribedTopic!]!.values.toList();
    }
    debugPrint('-> No stock data available for topic $_subscribedTopic');
    return [];
  }

  MqttService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await dotenv.load(fileName: ".env");
    _setupClient();
    await _connect();
  }

  void _setupClient() {
    final host = dotenv.env['SOLACE_HOST'] ?? 'mr-connection-6ne3htd4xcm.messaging.solace.cloud';
    final port = int.parse(dotenv.env['SOLACE_PORT']?.split(':').last ?? '8883');

    client = MqttServerClient.withPort(
      host,
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
      port,
    );
    client.secure = true;
    client.setProtocolV311();
    client.keepAlivePeriod = 120;
    client.logging(on: true); // Enable logging for debugging
    client.onBadCertificate = (Object? certificate) => true;
    client.onDisconnected = () => debugPrint('❌ Disconnected');
  }

  Future<void> _connect() async {
    final username = dotenv.env['SOLACE_USERNAME'] ?? 'admin';
    final password = dotenv.env['SOLACE_PASSWORD'] ?? 'admin';

    final connMess = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMess;

    client.autoReconnect = true;

    client.onConnected = () {
      debugPrint('✅ Connected to MQTT broker');
      if (_subscribedTopic != null) {
        subscribeToTopic(_subscribedTopic!);
      }
    };

    client.onDisconnected = () {
      debugPrint('❌ Disconnected from MQTT broker');
      notifyListeners(); // Notify UI of disconnection
    };

    client.onSubscribed = (String topic) {
      debugPrint('📌 Successfully subscribed to $topic');
    };

    client.onSubscribeFail = (String topic) {
      debugPrint('⚠️ Failed to subscribe to $topic');
    };

    try {
      await client.connect();
    } catch (e) {
      debugPrint('⛔ MQTT Connect Error: $e');
      client.disconnect();
      notifyListeners();
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    // Ensure connected
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      await _connect();
      const maxRetries = 5;
      int retry = 0;
      while (client.connectionStatus?.state != MqttConnectionState.connected && retry < maxRetries) {
        debugPrint('⏳ Waiting for MQTT to connect... (${retry + 1}/$maxRetries)');
        await Future.delayed(const Duration(seconds: 5));
        retry++;
      }

      if (client.connectionStatus?.state != MqttConnectionState.connected) {
        debugPrint('❌ Failed to connect to MQTT broker. Cannot subscribe.');
        notifyListeners();
        return;
      }
    }

    // Initialize stock data for the topic
    stockDataByTopic[topic] ??= {};

    // Unsubscribe from previous topic
    if (_subscribedTopic != null && _subscribedTopic != topic) {
      client.unsubscribe(_subscribedTopic!);
      debugPrint('🔄 Unsubscribed from $_subscribedTopic');
      await _subscription?.cancel();
    }

    _subscribedTopic = topic;
    client.subscribe(topic, MqttQos.atMostOnce);
    debugPrint('✅ Subscribed to $topic');

    _subscription = client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c == null || c.isEmpty) {
        debugPrint('⚠ MQTT update list is empty.');
        return;
      }

      final recMess = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      debugPrint('📥 Received payload: $payload');
      _handleMessage(payload);
    });

    notifyListeners();
  }

  void _handleMessage(String payload) {
    try {
      final Map<String, dynamic> stock = json.decode(payload);
      // Validate required fields
      if (!stock.containsKey('symbol') || !stock.containsKey('name') || !stock.containsKey('price')) {
        debugPrint('⚠ Invalid payload format: $payload');
        return;
      }

      final symbol = stock['symbol'];
      final double newPrice = stock['price'].toDouble();
      double change = 0;

      // Initialize topic map if not already there
      stockDataByTopic[_subscribedTopic!] ??= {};
      final previousStock = stockDataByTopic[_subscribedTopic!]![symbol];

      if (previousStock != null) {
        final double oldPrice = previousStock['price'];
        if ((newPrice - oldPrice).abs() < 0.01) return; // Skip micro changes

        if (oldPrice != 0) {
          change = ((newPrice - oldPrice) / oldPrice) * 100;
        }
      }

      stockDataByTopic[_subscribedTopic!]![symbol] = {
        'symbol': symbol,
        'name': stock['name'],
        'price': newPrice,
        'change': change,
        'stockTopic': stock['topic'] ?? _subscribedTopic,
      };

      debugPrint('✅ Updated stock: $symbol for topic $_subscribedTopic');
      notifyListeners();
    } catch (e) {
      debugPrint('⚠ Parse error: $e for payload: $payload');
    }
  }

  void disposeService() {
    _subscription?.cancel();
    client.disconnect();
    _subscribedTopic = null;
    notifyListeners();
  }
}