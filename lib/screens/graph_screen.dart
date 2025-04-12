import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import '/api_service.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late Future<List<Consumo>> _datosFuturos;
  int _horaInicio = 0;
  int _horaFin = 23;

  @override
  void initState() {
    super.initState();
    _datosFuturos = ApiService.obtenerConsumo();
  }

  //---- Funcion para dibujar un DropDown
  List<DropdownMenuItem<int>> _generarOpcionesHoras() {
    return List.generate(24, (index) {
      return DropdownMenuItem(value: index, child: Text('$index:00'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico de Consumo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<Consumo>>(
          future: _datosFuturos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final datos = snapshot.data!;

              // 🟡 Filtrar datos por hora seleccionada
              final datosFiltrados =
                  datos.where((d) {
                    final hora = int.parse(d.hora.split(':')[0]);
                    return hora >= _horaInicio && hora <= _horaFin;
                  }).toList();

              // 🟣 Imprimir los datos filtrados en consola
              print(
                '🔍 Datos filtrados para el rango $_horaInicio:00 - $_horaFin:00',
              );
              for (var d in datosFiltrados) {
                print('Hora: ${d.hora}, Amperios: ${d.amperios}');
              }

              if (datosFiltrados.isEmpty) {
                return const Center(
                  child: Text('No hay datos para el rango seleccionado.'),
                );
              }

              // 🔵 Convertir datos a puntos del gráfico
              final spots = List.generate(datosFiltrados.length, (index) {
                return FlSpot(index.toDouble(), datosFiltrados[index].amperios);
              });

              double calcularIntervaloEtiquetas() {
                final total = datosFiltrados.length;
                if (total <= 10) return 1;
                return (total / 10).floorToDouble();
              }

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Desde: "),
                      DropdownButton<int>(
                        value: _horaInicio,
                        items: _generarOpcionesHoras(),
                        onChanged: (valor) {
                          setState(() {
                            _horaInicio = valor!;
                            _datosFuturos = ApiService.obtenerConsumo();
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      const Text("Hasta: "),
                      DropdownButton<int>(
                        value: _horaFin,
                        items: _generarOpcionesHoras(),
                        onChanged: (valor) {
                          setState(() {
                            _horaFin = valor!;
                            _datosFuturos =
                                ApiService.obtenerConsumo(); // <-- vuelve a llamar la API
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 20,
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              interval: calcularIntervaloEtiquetas(),
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 &&
                                    index < datosFiltrados.length) {
                                  final hora = datosFiltrados[index].hora;
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Transform.rotate(
                                      angle: -1.5708, // -90 grados en radianes
                                      child: Text(
                                        hora,
                                        style: const TextStyle(fontSize: 10),
                                      ),
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
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: false,
                            color: Colors.blue,
                            barWidth: 2,
                            dotData: FlDotData(
                              show: false,
                            ), // 🔵 Sin circulitos
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
