import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/network/api_response_handler.dart';
import 'package:fase_2_consumo_api/src/data/models/product_model.dart';

abstract class ApiDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProductById(int id);
  Future<List<String>> getAllCategories();
}

class ApiDataSourceImpl implements ApiDataSource {
  final http.Client client;
  final ApiResponseHandler responseHandler;
  static const String BASE_URL = 'https://fakestoreapi.com';

  ApiDataSourceImpl({required this.client, required this.responseHandler});

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final uri = Uri.parse('$BASE_URL/products');
    try {
      final response = await client.get(uri);
      responseHandler.handleResponse(response);
      return (json.decode(response.body) as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } on http.ClientException {
      throw ConnectionException();
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final uri = Uri.parse('$BASE_URL/products/$id');
    try {
      final response = await client.get(uri);
      responseHandler.handleResponse(response);
      return ProductModel.fromJson(json.decode(response.body));
    } on http.ClientException {
      throw ConnectionException();
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    final uri = Uri.parse('$BASE_URL/products/categories');
    try {
      final response = await client.get(uri);
      responseHandler.handleResponse(response);
      return (json.decode(response.body) as List).cast<String>();
    } on http.ClientException {
      throw ConnectionException();
    }
  }
}
