import 'dart:convert';

import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/data/models/review_model.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'review_api.g.dart';

@riverpod
Future<List<ReviewModel>> fetchReviews(FetchReviewsRef ref,
    {required String userId}) async {
  Uri url = Uri.parse('$baseUrl/review?userId=$userId');


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
    final List<dynamic> data = json.decode(response.body)['data']['products'];
    print(response.body);
    List<ReviewModel> products = [];

    for (var item in data) {
      products.add(ReviewModel.fromJson(item));
    }
    print(products);
    return products;
  } else {
    print(json.decode(response.body)['message']);

    throw Exception(json.decode(response.body)['message']);
  }
}
