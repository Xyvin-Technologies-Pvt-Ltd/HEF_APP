import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';

import 'dart:async';

import 'package:hef/src/data/notifiers/products_notifier.dart';
import 'package:hef/src/interface/components/Cards/product_card.dart';
import 'package:hef/src/interface/components/ModalSheets/product_details.dart';
import 'package:hef/src/interface/components/shimmers/product_card_shimmer.dart';

class ProductView extends ConsumerStatefulWidget {
  const ProductView({super.key});

  @override
  ConsumerState<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<ProductView> {
  FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // _searchFocus.addListener(_onSearchFocusChange);
  }

  // void _onSearchFocusChange() {
  //   if (_searchFocus.hasFocus && !_hasSearched) {
  //     // Display all products when search bar is focused
  //     ref.read(productsNotifierProvider.notifier).fetchMoreProducts();
  //     _hasSearched = true; // Set flag to avoid fetching multiple times
  //   }
  // }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(productsNotifierProvider.notifier).fetchMoreProducts();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(productsNotifierProvider.notifier).searchProducts(query);
    });
  }

  void _onSearchSubmitted(String query) {
    // Perform search when search is submitted
    ref.read(productsNotifierProvider.notifier).searchProducts(query);
  }

  // void _showProductDetails(
  //     {required BuildContext context,
  //     required product,
  //     required Participant sender,
  //     required Participant receiver}) {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (context) => ProductDetailsModal(
  //       receiver: receiver,
  //       sender: sender,
  //       product: product,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final products = ref.watch(productsNotifierProvider);
      final isLoading = ref.read(productsNotifierProvider.notifier).isLoading;

      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (_searchFocus.hasFocus) {
            _searchFocus.unfocus();
          }
        },
        child: Scaffold(
            body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,

                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 216, 211, 211),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 216, 211, 211),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 216, 211, 211),
                        ),
                      ),
                    ),
                    onChanged: (query) =>
                        _onSearchChanged(query), // Trigger dynamic search
                    onSubmitted: (query) =>
                        _onSearchSubmitted(query), // Trigger search on submit
                  )),
              const SizedBox(height: 16),
              if (products.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 212,
                    crossAxisCount: 2,
                    crossAxisSpacing: 0.0,
                    mainAxisSpacing: 20.0,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return Consumer(
                      builder: (context, ref, child) {
                        final asyncProductOwner = ref.watch(
                            fetchUserDetailsProvider(
                                products[index].seller ?? ''));
                        return asyncProductOwner.when(
                          data: (productOwner) {
                            final receiver = Participant(
                                name: productOwner.name ?? '',
                                id: productOwner.uid,
                                image: productOwner.image);
                            return GestureDetector(
                              onTap: () => showProductDetails(
                                  receiver: receiver,
                                  sender: Participant(id: id),
                                  context: context,
                                  product: products[index]),
                              child: ProductCard(
                                isOthersProduct: true,
                                product: products[index],
                                onRemove: null,
                              ),
                            );
                          },
                          error: (error, stackTrace) {
                            log(error.toString());
                            return const SizedBox();
                          },
                          loading: () {
                            return SizedBox.shrink();
                          },
                        );
                      },
                    );
                  },
                )
              else if (!_hasSearched)
                Column(
                  children: [
                    const SizedBox(height: 100),
                    Image.asset('assets/pngs/searchproduct.png'),
                    const SizedBox(height: 20),
                    Text('Search required Products',
                        style: kHeadTitleB.copyWith(color: kGreyDark)),
                  ],
                )
              else
                const Column(
                  children: [
                    SizedBox(height: 100),
                    Text(
                      'No Products Found',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        )),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _searchFocus.dispose();
    super.dispose();
  }
}
