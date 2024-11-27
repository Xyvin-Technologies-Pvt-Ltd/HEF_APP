import 'dart:convert';

import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'products_api.g.dart';

@riverpod
Future<List<Product>> fetchProducts(FetchProductsRef ref,
    {int pageNo = 1, int limit = 10, String? search}) async {
  Uri url = Uri.parse('$baseUrl/products?pageNo=$pageNo&limit=$limit');

  if (search != null && search != '') {
    url = Uri.parse(
        '$baseUrl/products?pageNo=$pageNo&limit=$limit&search=$search');
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
