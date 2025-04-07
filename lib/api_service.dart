import 'dart:convert';
import 'package:http/http.dart' as http;

class Consumo {
  final String fecha;
  final String hora;
  final double amperios;
  final double consumoKwh;

  Consumo({
    required this.fecha,
    required this.hora,
    required this.amperios,
    required this.consumoKwh,
  });

  factory Consumo.fromJson(Map<String, dynamic> json) {
    return Consumo(
      fecha: json['fecha'],
      hora: json['hora'],
      amperios: json['amperios'],
      consumoKwh: json['consumo_kwh'],
    );
  }
}

class ApiService {
  static const String baseUrl = "http://54.207.201.160/:5000";

  static Future<List<Consumo>> obtenerConsumo() async {
    final response = await http.get(Uri.parse('$baseUrl/consumo'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Consumo.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener los datos');
    }
  }
}
