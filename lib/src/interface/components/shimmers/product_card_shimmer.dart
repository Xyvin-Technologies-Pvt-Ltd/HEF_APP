
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
      child: Container(
        width: double.infinity,
        child: Stack(
          children: [
            // Shimmer effect for the entire content
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer for the product image
                  Container(
                    height: 120.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                  ),
                  // Shimmer for the product details section
                  Container(
                    height: 80.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Shimmer for product name
                          Container(
                            height: 15.0,
                            width: 150.0,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8.0),
                          // Shimmer for price row
                          Row(
                            children: [
                              Container(
                                height: 15.0,
                                width: 50.0,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                height: 15.0,
                                width: 50.0,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          // Shimmer for MOQ
                          Container(
                            height: 12.0,
                            width: 100.0,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Static remove button (for demo purposes)
          ],
        ),
      ),
    );
  }
}
