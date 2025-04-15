// Paso 1: Estructura básica para scroll infinito con gráfico y filtros de hora

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/api_service.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  List<Consumo> _datos = [];
  int _offset = 0;
  final int _limit = 50;
  bool _isLoading = false;
  bool _hasMore = true;

  int _horaInicio = 0;
  int _horaFin = 2;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cargarDatos();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _cargarDatos();
      }
    });
  }

  Future<void> _cargarDatos() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final nuevos = await ApiService.obtenerConsumo(
        offset: _offset,
        limit: _limit,
      );

      print("➡️ Datos recibidos (${nuevos.length}):");
      for (var d in nuevos) {
        print("🕒 ${d.hora} | ⚡ ${d.amperios} A");
      }

      if (nuevos.isEmpty) {
        _hasMore = false;
      } else {
        setState(() {
          _datos.addAll(nuevos);
          _offset += _limit;
        });
      }
    } catch (e) {
      print("Error al cargar datos: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<DropdownMenuItem<int>> _generarOpcionesHoras() {
    return List.generate(
      24,
      (index) => DropdownMenuItem(value: index, child: Text('$index:00')),
    );
  }

  List<FlSpot> _generarSpots(List<Consumo> datosFiltrados) {
    return List.generate(
      datosFiltrados.length,
      (index) => FlSpot(index.toDouble(), datosFiltrados[index].amperios),
    );
  }

  double _intervaloEtiquetas(List<Consumo> datosFiltrados) {
    final total = datosFiltrados.length;
    if (total <= 10) return 1;
    return (total / 10).floorToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final datosFiltrados =
        _datos.where((d) {
          final hora = int.parse(d.hora.split(':')[0]);
          return hora >= _horaInicio && hora <= _horaFin;
        }).toList();

    print("📊 Total de datos acumulados: \${_datos.length}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico de Consumo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Desde: "),
                DropdownButton<int>(
                  value: _horaInicio,
                  items: _generarOpcionesHoras(),
                  onChanged: (valor) {
                    setState(() => _horaInicio = valor!);
                  },
                ),
                const SizedBox(width: 20),
                const Text("Hasta: "),
                DropdownButton<int>(
                  value: _horaFin,
                  items: _generarOpcionesHoras(),
                  onChanged: (valor) {
                    setState(() => _horaFin = valor!);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: [
                  SizedBox(
                    height: 400,
                    child:
                        _datos.isEmpty && _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : graficaDeLinea(datosFiltrados),
                  ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChart graficaDeLinea(List<Consumo> datosFiltrados) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 20,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: _intervaloEtiquetas(datosFiltrados),
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < datosFiltrados.length) {
                  final hora = datosFiltrados[index].hora;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Transform.rotate(
                      angle: -1.5708,
                      child: Text(hora, style: const TextStyle(fontSize: 10)),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 5,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _generarSpots(datosFiltrados),
            isCurved: false,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
