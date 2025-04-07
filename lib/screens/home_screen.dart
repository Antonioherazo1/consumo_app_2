import 'package:flutter/material.dart';
import '../mqtt_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _amperajeActual = 0.0;
  final MqttService _mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    _mqttService.onAmperajeReceived = (valor) {
      setState(() {
        _amperajeActual = valor;
      });
    };
    _mqttService.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumo de Energía'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Amperaje Actual: ${_amperajeActual.toStringAsFixed(2)} A',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
