import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttAmperiosWidget extends StatefulWidget {
  const MqttAmperiosWidget({super.key});

  @override
  State<MqttAmperiosWidget> createState() => _MqttAmperiosWidgetState();
}

class _MqttAmperiosWidgetState extends State<MqttAmperiosWidget> {
  final client = MqttServerClient('thinc.site', '');
  String amperajeActual = '---';

  @override
  void initState() {
    super.initState();
    conectarAlBroker();
  }

  Future<void> conectarAlBroker() async {
    client.port = 1883;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = () {
      print('🔌 Desconectado');
    };

    try {
      await client.connect();
      print('✅ Conectado al broker MQTT');

      client.subscribe('consumo/amps_Total', MqttQos.atMostOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final message = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );

        print('📥 Mensaje recibido: $message');

        setState(() {
          amperajeActual = message;
        });
      });
    } catch (e) {
      print('❌ Error al conectar: $e');
      client.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Amperios actuales: $amperajeActual A',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
