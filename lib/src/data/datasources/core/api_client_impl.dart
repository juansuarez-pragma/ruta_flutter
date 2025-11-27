import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fase_2_consumo_api/src/core/config/env_config.dart';
import 'package:fase_2_consumo_api/src/core/errors/connection_exception.dart';
import 'package:fase_2_consumo_api/src/core/network/api_response_handler.dart';
import 'package:fase_2_consumo_api/src/data/datasources/core/api_client.dart';

/// Implementación concreta de [ApiClient] usando el paquete `http`.
///
/// Centraliza toda la lógica común de peticiones HTTP:
/// - Construcción de URLs con base URL desde configuración
/// - Manejo de excepciones de conexión
/// - Validación de respuestas HTTP
/// - Decodificación de JSON
///
/// Los DataSources específicos usan esta clase para realizar peticiones
/// sin duplicar código de manejo de errores y parseo.
class ApiClientImpl implements ApiClient {
  final http.Client _client;
  final ApiResponseHandler _responseHandler;
  final EnvConfig _config;

  ApiClientImpl({
    required http.Client client,
    required ApiResponseHandler responseHandler,
    EnvConfig? config,
  }) : _client = client,
       _responseHandler = responseHandler,
       _config = config ?? EnvConfig.instance;

  String get _baseUrl => _config.apiBaseUrl;

  @override
  Future<T> get<T>({
    required String endpoint,
    required T Function(dynamic json) fromJson,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await _client.get(uri);
      _responseHandler.handleResponse(response);
      return fromJson(json.decode(response.body));
    } on http.ClientException catch (e) {
      throw ConnectionException(uri: uri, originalError: e.message);
    }
  }

  @override
  Future<List<T>> getList<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJsonList,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await _client.get(uri);
      _responseHandler.handleResponse(response);
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((item) => fromJsonList(item as Map<String, dynamic>))
          .toList();
    } on http.ClientException catch (e) {
      throw ConnectionException(uri: uri, originalError: e.message);
    }
  }

  @override
  Future<List<T>> getPrimitiveList<T>({required String endpoint}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    try {
      final response = await _client.get(uri);
      _responseHandler.handleResponse(response);
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.cast<T>();
    } on http.ClientException catch (e) {
      throw ConnectionException(uri: uri, originalError: e.message);
    }
  }
}
