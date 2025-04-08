import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'products_api.g.dart';

class ProductApiService {
  final _headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };

  /// Fetch all products (with optional pagination and search)
  Future<List<Product>> fetchProducts({
    int pageNo = 1,
    int limit = 10,
    String? search,
  }) async {
    Uri url = Uri.parse('$baseUrl/product?pageNo=$pageNo&limit=$limit');

    if (search != null && search.isNotEmpty) {
      url = Uri.parse(
          '$baseUrl/product?pageNo=$pageNo&limit=$limit&search=$search');
    }

    log('Requesting URL: $url');

    final response = await http.get(url, headers: _headers);
    final responseData = json.decode(response.body);
    log('Status: ${responseData['status']}');

    if (response.statusCode == 200) {
      final List data = responseData['data'];
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      final message = responseData['message'];
      log('Error: $message');
      throw Exception(message);
    }
  }

  /// Fetch products created by the current user
  Future<List<Product>> fetchMyProducts() async {
    final url = Uri.parse('$baseUrl/product/myproducts');
    log('Requesting URL: $url');

    final response = await http.get(url, headers: _headers);
    final responseData = json.decode(response.body);
    log('Status: ${responseData['status']}');

    if (response.statusCode == 200) {
      final List data = responseData['data'];
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      final message = responseData['message'];
      log('Error: $message');
      throw Exception(message);
    }
  }

  /// Update an existing product
  Future<void> updateProduct(Product product) async {
    try {
      final productData = product.toJson()
        ..remove('id')
        ..remove('createdAt')
        ..remove('updatedAt')
        ..['status'] = 'pending';

      final url = Uri.parse('$baseUrl/product/single/${product.id}');
      log('Updating Product: ${productData.toString()}');

      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode(productData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        log('Product updated successfully: ${responseData['message']}');
      } else {
        log('Failed to update product: $responseData');
        throw Exception(responseData['message'] ?? 'Unknown error');
      }
    } catch (e) {
      log('Exception in updateProduct: $e');
      throw Exception('Failed to update product: $e');
    }
  }
}
@riverpod
Future<List<Product>> fetchProducts(
  FetchProductsRef ref, {
  int pageNo = 1,
  int limit = 10,
  String? search,
}) async {
  final service = ProductApiService();
  return service.fetchProducts(pageNo: pageNo, limit: limit, search: search);
}

@riverpod
Future<List<Product>> fetchMyProducts(FetchMyProductsRef ref) async {
  final service = ProductApiService();
  return service.fetchMyProducts();
}
