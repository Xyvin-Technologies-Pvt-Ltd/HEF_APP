import 'dart:developer';

import 'package:hef/src/data/api_routes/products_api/products_api.dart';
import 'package:hef/src/data/models/product_model.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products_notifier.g.dart';

@riverpod
class ProductsNotifier extends _$ProductsNotifier {
  List<Product> products = [];
  bool isLoading = false;
  String? errorMessage;
  int pageNo = 1;
  final int limit = 20;
  bool hasMore = true;

  @override
  List<Product> build() {
    return [];
  }

  void removeProductsBySeller(String sellerId) {
    products = products.where((product) => product.seller != sellerId).toList();
    state = products;
  }

  Future<void> fetchMoreProducts() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    errorMessage = null;
    state = [...products];

    try {
      final newProducts = await ref
          .read(fetchProductsProvider(pageNo: pageNo, limit: limit).future);
      products = [...products, ...newProducts];
      pageNo++;
      hasMore = newProducts.length == limit;
      state = products;
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
      state = [...products];
    }
  }

  Future<void> searchProducts(String query) async {
    isLoading = true;
    errorMessage = null;
    pageNo = 1;
    products = []; // Reset the product list when searching
    state = [];

    try {
      final newProducts = await ref.read(
          fetchProductsProvider(pageNo: pageNo, limit: limit, search: query)
              .future);
      products = [...newProducts];
      hasMore = newProducts.length == limit;
      state = products;
    } catch (e, stackTrace) {
      errorMessage = e.toString();
      log(e.toString());
      log(stackTrace.toString());
    } finally {
      isLoading = false;
      state = [...products];
    }
  }
}
