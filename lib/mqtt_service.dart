import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

typedef OnAmperajeReceived = void Function(double amperaje);

class MqttService {
  final String broker = 'thinc.site';
  final int port = 1883;
  final String topic = 'consumo/amps_Total';
  final String clientId = 'flutter_cliente';

  late MqttServerClient client;
  OnAmperajeReceived? onAmperajeReceived;

  Future<void> connect() async {
    client = MqttServerClient(broker, clientId);
    client.port = port;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.logging(on: false);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      _subscribeToTopic();
    } catch (e) {
      client.disconnect();
    }

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      final amperaje = double.tryParse(payload);
      if (amperaje != null && onAmperajeReceived != null) {
        onAmperajeReceived!(amperaje);
      }
    });
  }

  void _subscribeToTopic() {
    client.subscribe(topic, MqttQos.atMostOnce);
  }

  void _onDisconnected() {
    print('Desconectado del broker MQTT');
  }
}
