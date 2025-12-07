// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:lab2/services/plant_storage.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MQTTService {
  final client = MqttClient('broker.hivemq.com', '');

  void connect(PlantStorage storage, String email) async {
    client.port = 1883;
    client.keepAlivePeriod = 20;

    client.onConnected = () {
      print('MQTT connected');
      _subscribeToHumidity(email);
    };

    client.onDisconnected = () {
      print('MQTT disconnected');
    };

    try {
      await client.connect();
    } catch (e) {
      print('Connection error: $e');
      client.disconnect();
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> events) {
      final MqttPublishMessage recMess = 
      events[0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message
      );

      print('Humidity received: $pt');

      try {
        final data = jsonDecode(pt);
        final plantId = data['plantId'];
        final humidity = (data['humidity'] as num).toDouble();

        // ❗ Безпечне оновлення рослини
        final plantIndex = storage.plants.indexWhere((p) => p.id == plantId);
        if (plantIndex != -1) {
          storage.plants[plantIndex].waterLevel = humidity / 100;
          storage.savePlants(storage.plants);
        }
      } catch (e) {
        print('Error parsing MQTT data: $e');
      }
    });
  }

  void _subscribeToHumidity(String email) {
    final topic = 'plants/$email/humidity';
    print('Subscribing to $topic');
    client.subscribe(topic, MqttQos.atMostOnce);
  }
}
