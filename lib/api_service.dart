// -----------------------------------------------------------------------------
// Sección: Imports
// -----------------------------------------------------------------------------

import 'dart:convert'; // Importa la biblioteca 'dart:convert' para trabajar con la codificación y decodificación de datos, como JSON.
import 'package:http/http.dart'
    as http; // Importa la biblioteca 'http' del paquete 'http' y le asigna el alias 'http' para realizar solicitudes HTTP.

// -----------------------------------------------------------------------------
// Sección: Clase Consumo (Modelo de Datos)
// -----------------------------------------------------------------------------

class Consumo {
  // Clase modelo para representar un dato de consumo.
  final String fecha; // Fecha del registro de consumo.
  final String hora; // Hora del registro de consumo.
  final double amperios; // Valor de los amperios en el registro.
  final double consumoKwh; // Valor del consumo en kWh en el registro.

  Consumo({
    // Constructor de la clase Consumo.
    required this.fecha,
    required this.hora,
    required this.amperios,
    required this.consumoKwh,
  });

  factory Consumo.fromJson(Map<String, dynamic> json) {
    // Método factory para crear una instancia de Consumo desde un mapa JSON.
    return Consumo(
      fecha: json['fecha'], // Obtiene el valor de la clave 'fecha' del JSON.
      hora: json['hora'], // Obtiene el valor de la clave 'hora' del JSON.
      amperios:
          (json['amperios'] as num)
              .toDouble(), // Obtiene el valor de la clave 'amperios' del JSON, lo castea a 'num' (para manejar tanto int como double) y luego lo convierte a 'double'.
      consumoKwh:
          (json['consumo_kwh'] as num)
              .toDouble(), // Obtiene el valor de la clave 'consumo_kwh' del JSON, lo castea a 'num' y luego lo convierte a 'double'.
    );
  }
}

// -----------------------------------------------------------------------------
// Sección: Clase ApiService (Servicio de API)
// -----------------------------------------------------------------------------

class ApiService {
  // Clase que contiene métodos estáticos para interactuar con la API.
  static const String baseUrl =
      'http://54.207.201.160:5000'; // Define una constante estática para la URL base de la API.

  // ---------------------------------------------------------------------------
  // Sección: Método estático obtenerConsumo()
  // ---------------------------------------------------------------------------

  static Future<List<Consumo>> obtenerConsumo({
    // Método estático asíncrono para obtener una lista de objetos Consumo desde la API.
    int offset =
        0, // Parámetro opcional para la paginación, indica el punto de inicio de los datos a solicitar (por defecto es 0).
    int limit =
        500, // Parámetro opcional para la paginación, indica la cantidad de datos a solicitar (por defecto es 50).
  }) async {
    // Construye la URL completa para la solicitud GET, incluyendo los parámetros de offset y limit.
    final url = Uri.parse('$baseUrl/consumo?offset=$offset&limit=$limit');

    try {
      // Bloque try-catch para manejar posibles errores durante la llamada a la API.
      final response = await http.get(
        url,
      ); // Realiza una solicitud HTTP GET a la URL construida. La palabra clave 'await' indica que esta operación es asíncrona.

      if (response.statusCode == 200) {
        // Verifica si la respuesta de la API fue exitosa (código de estado 200 OK).
        final List<dynamic> data = json.decode(
          response.body,
        ); // Decodifica el cuerpo de la respuesta (que se espera que sea JSON) en una lista dinámica.
        return data
            .map(
              (json) => Consumo.fromJson(json),
            ) // Itera sobre cada elemento (que se espera que sea un mapa JSON) en la lista 'data' y lo convierte a un objeto Consumo utilizando el método factory 'fromJson'.
            .toList(); // 🔁 Convierte el resultado del 'map' (un Iterable) a una lista de objetos Consumo.
      } else {
        // Si la respuesta de la API no fue exitosa, lanza una excepción con el código de estado y la razón del error.
        throw Exception(
          'Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // Captura cualquier excepción que ocurra durante la llamada a la API (por ejemplo, problemas de red).
      throw Exception(
        'Excepción al obtener datos: $e',
      ); // Lanza una nueva excepción con un mensaje descriptivo del error.
    }
  }
}
