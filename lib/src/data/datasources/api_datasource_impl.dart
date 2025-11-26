import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:fase_2_consumo_api/src/core/config/env_config.dart';
import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/core/errors/connection_exception.dart';
import 'package:fase_2_consumo_api/src/core/network/api_response_handler.dart';
import 'package:fase_2_consumo_api/src/data/datasources/api_datasource.dart';
import 'package:fase_2_consumo_api/src/data/models/product_model.dart';

/// Implementación concreta del origen de datos de la API.
class ApiDataSourceImpl implements ApiDataSource {
  final http.Client client;
  final ApiResponseHandler responseHandler;
  final EnvConfig _config;

  ApiDataSourceImpl({
    required this.client,
    required this.responseHandler,
    EnvConfig? config,
  }) : _config = config ?? EnvConfig.instance;

  String get _baseUrl => _config.apiBaseUrl;

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.products}');
    try {
      final response = await client.get(uri);
      responseHandler.handleResponse(response);
      return (json.decode(response.body) as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } on http.ClientException {
      throw const ConnectionException();
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.productById(id)}');
    try {
      final response = await client.get(uri);
      responseHandler.handleResponse(response);
      return ProductModel.fromJson(json.decode(response.body));
    } on http.ClientException {
      throw const ConnectionException();
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.categories}');
    try {
      final response = await client.get(uri);
      responseHandler.handleResponse(response);
      return (json.decode(response.body) as List).cast<String>();
    } on http.ClientException {
      throw const ConnectionException();
    }
  }
}
