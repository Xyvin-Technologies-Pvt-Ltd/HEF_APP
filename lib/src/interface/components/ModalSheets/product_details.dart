import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/chat_api/chat_api.dart';
import 'package:hef/src/data/api_routes/review_api/review_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/common/review_barchart.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:hef/src/interface/screens/main_pages/chat/chat_screen.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailsModal extends ConsumerStatefulWidget {
  final Product product;
  final Participant receiver;
  final Participant sender;

  const ProductDetailsModal(
      {super.key,
      required this.product,
      required this.receiver,
      required this.sender});

  @override
  _ProductDetailsModalState createState() => _ProductDetailsModalState();
}

class _ProductDetailsModalState extends ConsumerState<ProductDetailsModal> {
  TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.product.moq.toString() ?? '0';
  }

  @override
  void dispose() {
    _quantityController.dispose();

    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      int currentValue = int.tryParse(_quantityController.text) ?? 0;
      _quantityController.text = (currentValue + 1).toString();
    });
  }

  void _decrementQuantity() {
    setState(() {
      int currentValue = int.tryParse(_quantityController.text) ?? 0;
      if (currentValue > 0 &&
          currentValue > num.parse(widget.product.moq.toString())) {
        _quantityController.text = (currentValue - 1).toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final asyncUser =
            ref.watch(fetchUserDetailsProvider(widget.product.seller!));
        final asyncReviews = ref
            .watch(fetchReviewsProvider(userId: widget.product.seller ?? ''));
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                          20), // Set the desired radius for the top left corner
                      topRight: Radius.circular(
                          20), // Set the desired radius for the top right corner
                    ),
                    child: Image.network(
                      widget.product.image!, // Replace with your image URL
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Text(
                        widget.product.name!,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                widget.product.offerPrice != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Text(
                              'INR ${widget.product.price} / piece',
                              style: TextStyle(
                                decoration: widget.product.offerPrice != null
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration:
                                  const BoxDecoration(color: Colors.black),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                child: Text(
                                  'INR ${widget.product.offerPrice?.toDouble()} / piece',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        'INR ${widget.product.price} / piece',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                if (widget.product.moq != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Text(
                          'MOQ : ${widget.product.moq}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      Expanded(
                        // Wrap the Text widget in Expanded to prevent overflow issues
                        child: Text(
                          widget.product.description ?? '',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                asyncUser.when(
                  data: (user) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: ClipOval(
                              child: Image.network(
                                user.image ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                      'assets/icons/dummy_person_small.png');
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    '${user.name ?? ''}'),
                                Text('${user.company?[0].name ?? ''}'),
                              ],
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              return asyncReviews.when(
                                data: (reviews) {
                                  final averageRating =
                                      getAverageRating(reviews);
                                  final totalReviews = reviews.length;
                                  return Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 15,
                                      ),
                                      Text(
                                        averageRating.toStringAsFixed(2),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text('($totalReviews)',
                                          style: const TextStyle(fontSize: 12)),
                                    ],
                                  );
                                },
                                loading: () =>
                                    const Center(child: LoadingAnimation()),
                                error: (error, stackTrace) {
                                  return Center(
                                    child: SizedBox.shrink(),
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(child: LoadingAnimation()),
                  error: (error, stackTrace) {
                    return const Center(
                        child: Text('Something Went Wrong, Please try again'));
                  },
                ),
                const SizedBox(height: 16),
                if (id != widget.product.seller)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _decrementQuantity(),
                        child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFEFEFEF),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.remove),
                            )),
                      ),
                      if (id != widget.product.seller)
                        const SizedBox(width: 16),
                      if (id != widget.product.seller)
                        SizedBox(
                            height: 40,
                            width:
                                210, // Increase this value to expand the horizontal width
                            child: TextField(
                              style: const TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                // Border when the field is not focused and enabled
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 224, 218,
                                        218), // Default border color
                                    width: 1.0,
                                  ),
                                ),

                                // Border when the field is focused
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 220, 223,
                                        226), // Border color when focused
                                    width: 2.0,
                                  ),
                                ),

                                // Border when the field is disabled
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Colors.grey
                                        .shade400, // Lighter grey for disabled state
                                    width: 1.0,
                                  ),
                                ),

                                // Border when an error is present (e.g., validation failed)
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors
                                        .red, // Red border for error state
                                    width: 1.0,
                                  ),
                                ),

                                // Border when the field is both focused and has an error
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors
                                        .red, // Red border when focused and has an error
                                    width: 2.0,
                                  ),
                                ),

                                // Padding inside the TextField
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                              ),
                              onChanged: (value) {
                                // Ensure only valid numbers are allowed
                                if (int.tryParse(value) == null) {
                                  _quantityController.text = '0';
                                }
                              },
                            )),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _incrementQuantity(),
                        child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFEFEFEF),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.add),
                            )),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (id != widget.product.seller)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customButton(
                        label: 'Get Quote',
                        onPressed: () async {
                          await sendChatMessage(
                              productId: widget.product.id,
                              userId: widget.product.seller!,
                              content:
                                  '''I need ${_quantityController.text}\nLet\'s Connect!''');

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => IndividualPage(
                                    receiver: widget.receiver,
                                    sender: widget.sender,
                                  )));
                        },
                        fontSize: 16),
                  ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

void showProductDetails(
    {required BuildContext context,
    required product,
    required Participant sender,
    required Participant receiver}) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) => ProductDetailsModal(
      receiver: receiver,
      sender: sender,
      product: product,
    ),
  );
}
