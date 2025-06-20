import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hef/src/data/api_routes/products_api/products_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/edit_user.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:hef/src/interface/components/Cards/product_card.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/menuPages/add_product.dart';
import 'package:path/path.dart';
import '../../../../data/services/navgitor_service.dart';

class MyProductPage extends ConsumerStatefulWidget {
  MyProductPage({super.key});

  @override
  ConsumerState<MyProductPage> createState() => _MyProductPageState();
}

class _MyProductPageState extends ConsumerState<MyProductPage> {
  TextEditingController productPriceType = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController productMoqController = TextEditingController();
  final TextEditingController productActualPriceController =
      TextEditingController();
  final TextEditingController productOfferPriceController =
      TextEditingController();
  File? _productImageFIle;

  String productUrl = '';


  Future<void> _editProduct(
      int index, Product oldProduct, BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EnterProductsPage(
                  imageUrl: oldProduct.image,
                  isEditing: true,
                  product: oldProduct,
                  onEdit: (Product updatedProduct) async {
             final service = ProductApiService();
                    await service.updateProduct(updatedProduct);
                  },
                )));
  }

  void _removeProduct(String productId) async {
    deleteProduct(productId);
    ref.invalidate(fetchMyProductsProvider);
  }

  void _openModalSheet({required String sheet}) {
    if (sheet == 'product') {
      NavigationService navigationService = NavigationService();
      navigationService.pushNamed('EnterProductsPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncProducts = ref.watch(fetchMyProductsProvider);
        return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                "My Products",
                style: TextStyle(fontSize: 17),
              ),
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return asyncProducts.when(
                        data: (products) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _InfoCard(
                                    title: 'Products',
                                    count: products.length.toString(),
                                  ),
                                  // const _InfoCard(title: 'Messages', count: '30'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const SizedBox(height: 16),
                              Expanded(
                                child: GridView.builder(
                                  shrinkWrap:
                                      true, // Let GridView take up only as much space as it needs
                                  // Disable GridView's internal scrolling
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisExtent: 212,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 0.0,
                                    mainAxisSpacing: 20.0,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    return ProductCard(
                                        onEdit: () => _editProduct(
                                            index, products[index], context),
                                        product: products[index],
                                        onRemove: () => _removeProduct(
                                            products[index].id ?? ''));
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(child: LoadingAnimation()),
                        error: (error, stackTrace) {
                          return Center(
                            child: Text('No Products'),
                          );
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 36,
                  right: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      _openModalSheet(sheet: 'product');
                    },
                    label: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        'Add Product',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 27,
                    ),
                    backgroundColor: kPrimaryColor,
                  ),
                ),
              ],
            ));
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String count;

  const _InfoCard({
    Key? key,
    required this.title,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
