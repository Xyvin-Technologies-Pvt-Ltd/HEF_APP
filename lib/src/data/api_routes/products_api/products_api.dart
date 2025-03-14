import 'dart:convert';

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

Future<bool?> updateProduct({
  required String productId,
  required String name,
  required String price,
  required String offerPrice,
  required String description,
  required String moq,
  required String productImage,
 
  required String productPriceType,
}) async {


  SnackbarService snackbarService = SnackbarService();
  final String url = '$baseUrl/product/single/${productId}';
  final Map<String, String> headers = {
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  final Map<String, String> body = {
    
  "name":name,
  "image": productImage,
  "price": price,
  "offerPrice": offerPrice,
  "description": description,
  "moq":  moq,
  "units":  productPriceType,
  "status":  'pending',
  };
  final response = await http.put(
    Uri.parse(url),
    headers: headers,    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final dynamic body = json.decode(response.body);

    print(body);
    return true;
  } else {
    print(json.decode(response.body)['message']);
    snackbarService.showSnackBar(json.decode(response.body)['message']);
    return false;

  }
}
