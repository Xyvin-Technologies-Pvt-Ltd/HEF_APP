import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/data/services/snackbar_service.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'products_api.g.dart';

@riverpod
Future<List<Product>> fetchProducts(Ref ref,
    {int pageNo = 1, int limit = 10, String? search}) async {
  Uri url = Uri.parse('$baseUrl/product?pageNo=$pageNo&limit=$limit');

  if (search != null && search != '') {
    url = Uri.parse(
        '$baseUrl/product?pageNo=$pageNo&limit=$limit&search=$search');
  }

  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );
  print('hello');
  print(json.decode(response.body)['status']);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    print(response.body);
    List<Product> products = [];

    for (var item in data) {
      products.add(Product.fromJson(item));
    }
    print(products);
    return products;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

@riverpod
Future<List<Product>> fetchMyProducts(
  Ref ref,
) async {
  Uri url = Uri.parse('$baseUrl/product/myproducts');

  print('Requesting URL: $url');
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );
  print('hello');
  print(json.decode(response.body)['status']);
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body)['data'];
    print(response.body);
    List<Product> products = [];

    for (var item in data) {
      products.add(Product.fromJson(item));
    }
    print(products);
    return products;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}

Future<void> updateProduct(Product product) async {
  try {
    final productData = product.toJson();
    productData.remove('id');
    productData.remove('createdAt');
    productData.remove('updatedAt');

    productData['status'] = 'pending';

    final response = await http.patch(
      Uri.parse('$baseUrl/product/single/${product.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(productData),
    );
    log(productData.toString());
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      log('Product updated successfully: ${responseData['message']}');
    } else {
      log('Failed to update product. Status Code: ${response.statusCode}, Response: $responseData');
      throw Exception(
          'Failed to update product: ${responseData['message'] ?? 'Unknown error'}');
    }
  } catch (e) {
    log('Exception in updateProduct: $e');
    throw Exception('Failed to update product: $e');
  }
}
