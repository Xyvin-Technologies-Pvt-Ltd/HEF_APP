import 'dart:developer';
import 'dart:io';
import 'package:hef/src/data/api_routes/products_api/products_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/data/notifiers/user_notifier.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/edit_user.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:permission_handler/permission_handler.dart';

class EnterProductsPage extends ConsumerStatefulWidget {
  final bool isEditing;
  final Product? product;
  final Function(Product)? onEdit;
  final String? imageUrl;
  const EnterProductsPage({
    this.imageUrl,
    super.key,
    this.isEditing = false,
    this.product,
    this.onEdit,
  });

  @override
  ConsumerState<EnterProductsPage> createState() => _EnterProductsPageState();
}

class _EnterProductsPageState extends ConsumerState<EnterProductsPage> {
  File? productImage;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController productPriceType;
  late TextEditingController productNameController;
  late TextEditingController productDescriptionController;
  late TextEditingController productMoqController;
  late TextEditingController productActualPriceController;
  late TextEditingController productOfferPriceController;

  @override
  void initState() {
    super.initState();
    productPriceType = TextEditingController(
        text: widget.isEditing
            ? widget.product?.productPriceType
            : "Price per unit");
    productNameController = TextEditingController(
        text: widget.isEditing ? widget.product?.name : '');
    productDescriptionController = TextEditingController(
        text: widget.isEditing ? widget.product?.description : '');
    productMoqController = TextEditingController(
        text: widget.isEditing ? widget.product?.moq?.toString() : '');
    productActualPriceController = TextEditingController(
        text: widget.isEditing ? widget.product?.price?.toString() : '');
    productOfferPriceController = TextEditingController(
        text: widget.isEditing ? widget.product?.offerPrice?.toString() : '');
  }

  @override
  void dispose() {
    productPriceType.dispose();
    productNameController.dispose();
    productDescriptionController.dispose();
    productMoqController.dispose();
    productActualPriceController.dispose();
    productOfferPriceController.dispose();
    super.dispose();
  }

  Future<bool> _addNewProduct() async {
    final createdProduct = await uploadProduct(
      name: productNameController.text,
      price: productActualPriceController.text,
      offerPrice: productOfferPriceController.text,
      description: productDescriptionController.text,
      moq: productMoqController.text,
      productImage: await imageUpload(productImage!.path),
      productPriceType: productPriceType.text,
    );

    if (createdProduct == null) {
      print('couldnt create new product');
      return false;
    } else {
      final newProduct = Product(
        id: createdProduct.id,
        name: productNameController.text,
        image: await imageUpload(productImage!.path),
        description: productDescriptionController.text,
        moq: int.tryParse(productMoqController.text),
        offerPrice: double.tryParse(productOfferPriceController.text),
        price: double.tryParse(productActualPriceController.text),
        seller: id,
        productPriceType: productPriceType.text,
        status: 'pending',
      );
    }
    return true;
  }

  Future<File?> _pickFile({required String imageType}) async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Photo access is required to pick images. Please enable it from Settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return null;
      }
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _validateAndSubmit() async {
    if (productImage == null && !widget.isEditing) {
      _showSnack('Please upload an image');
      return;
    }

    if (productNameController.text.trim().isEmpty) {
      _showSnack('Please enter a product name');
      return;
    }

    final offer = productOfferPriceController.text.trim();
    final actual = productActualPriceController.text.trim();

    if (offer.isNotEmpty && actual.isEmpty) {
      _showSnack('Please enter actual price when offer price is provided');
      return;
    }

    if (offer.isNotEmpty && actual.isNotEmpty) {
      double offerVal = double.tryParse(offer) ?? 0;
      double actualVal = double.tryParse(actual) ?? 0;
      if (offerVal >= actualVal) {
        _showSnack('Actual price must be greater than offer price');
        return;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: LoadingAnimation()),
    );

    try {
      if (widget.isEditing && widget.onEdit != null) {
        final updatedProduct = Product(
          id: widget.product!.id,
          name: productNameController.text,
          description: productDescriptionController.text,
          moq: int.tryParse(productMoqController.text),
          price: double.tryParse(productActualPriceController.text),
          offerPrice: double.tryParse(productOfferPriceController.text),
          productPriceType: productPriceType.text,
          image: productImage != null
              ? await imageUpload(productImage!.path)
              : widget.product?.image,
          seller: widget.product?.seller,
          status: "pending",
        );

        await widget.onEdit!(updatedProduct);
        ref.invalidate(fetchMyProductsProvider);
      } else {
        await _addNewProduct();
      }

      productNameController.clear();
      productDescriptionController.clear();
      productMoqController.clear();
      productActualPriceController.clear();
      productOfferPriceController.clear();
      productPriceType.clear();
      setState(() {
        productImage = null;
      });
    } finally {
      Navigator.of(context).pop();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 231, 226, 226),
                  width: 1.0,
                ),
              ),
            ),
            child: AppBar(
              toolbarHeight: 45.0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: 100,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(scale: 5, 'assets/pngs/splash_logo.png'),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Column(
                    children: [
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_back,
                            color: Colors.blue,
                            size: 17,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Add Product/Service',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: KeyboardAvoider(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormField<File>(
                      initialValue: productImage,
                      validator: (value) {
                        if (value == null) {
                          if (!widget.isEditing) {
                            return 'Please upload an image';
                          } else {
                            return null;
                          }
                        }
                        return null;
                      },
                      builder: (FormFieldState<File> state) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                      child: LoadingAnimation(),
                                    );
                                  },
                                );

                                final pickedFile =
                                    await _pickFile(imageType: 'product');
                                if (pickedFile == null) {
                                  Navigator.pop(context);
                                }

                                setState(() {
                                  productImage = pickedFile;
                                  state.didChange(
                                      pickedFile); // Update form state
                                });

                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 110,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  border: state.hasError
                                      ? Border.all(color: Colors.red)
                                      : null,
                                ),
                                child: productImage == null
                                    ? widget.imageUrl != null
                                        ? Center(
                                            child: Image.network(
                                                widget.imageUrl ?? ''),
                                          )
                                        : const Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.add,
                                                    size: 27,
                                                    color: Color(0xFF004797)),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Upload Image',
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 102, 101, 101)),
                                                ),
                                              ],
                                            ),
                                          )
                                    : Center(
                                        child: Image.file(
                                          productImage!,
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                        ),
                                      ),
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  state.errorText!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ModalSheetTextFormField(
                      textController: productNameController,
                      label: 'Add name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ModalSheetTextFormField(
                      textController: productDescriptionController,
                      label: 'Add description',
                      maxLines: 4,
                      // No validator
                    ),
                    const SizedBox(height: 10),
                    ModalSheetTextFormField(
                      textInputType: const TextInputType.numberWithOptions(),
                      textController: productMoqController,
                      label: 'Add MOQ',
                      // No validator
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: ModalSheetTextFormField(
                            textInputType:
                                const TextInputType.numberWithOptions(),
                            textController: productActualPriceController,
                            label: 'Actual price',
                            // No validator
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: ModalSheetTextFormField(
                            textInputType:
                                const TextInputType.numberWithOptions(),
                            textController: productOfferPriceController,
                            label: 'Offer price',
                            // No validator
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 185, 181, 181),
                            width: 1.0,
                          ),
                        ),
                      ),
                      onPressed: () {
                        _showProductPriceTypeDialog(context).then((value) {
                          if (value != null) {
                            setState(() {
                              productPriceType.text = value;
                            });

                            log('Selected price per unit: ${productPriceType}');
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productPriceType.text,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 94, 93, 93)),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    customButton(
                      label: widget.isEditing ? 'UPDATE' : 'SAVE',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Custom validation for offer/actual price
                          final offer = productOfferPriceController.text.trim();
                          final actual =
                              productActualPriceController.text.trim();
                          if (offer.isNotEmpty && actual.isEmpty) {
                            _showSnack(
                                'Please enter actual price when offer price is provided');
                            return;
                          }
                          if (offer.isNotEmpty && actual.isNotEmpty) {
                            double offerVal = double.tryParse(offer) ?? 0;
                            double actualVal = double.tryParse(actual) ?? 0;
                            if (offerVal >= actualVal) {
                              _showSnack(
                                  'Actual price must be greater than offer price');
                              return;
                            }
                          }
                          if (widget.isEditing) {
                            // Show confirmation dialog before updating the product
                            final bool confirmUpdate = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Update"),
                                content: const Text(
                                    "If you update this product, you will need to wait for admin approval again. Do you want to proceed?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false), // Cancel
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true), // Confirm
                                    child: const Text("Proceed"),
                                  ),
                                ],
                              ),
                            );

                            if (!confirmUpdate)
                              return; // If user cancels, do nothing
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) =>
                                const Center(child: LoadingAnimation()),
                          );
                          bool success = false;
                          try {
                            if (widget.isEditing && widget.onEdit != null) {
                              final updatedProduct = Product(
                                id: widget.product!.id,
                                name: productNameController.text,
                                description: productDescriptionController.text,
                                moq: int.tryParse(productMoqController.text),
                                price: double.tryParse(
                                    productActualPriceController.text),
                                offerPrice: double.tryParse(
                                    productOfferPriceController.text),
                                productPriceType: productPriceType.text,
                                image: productImage != null
                                    ? await imageUpload(productImage!.path)
                                    : widget.product?.image,
                                seller: widget.product?.seller,
                                status: "pending",
                              );

                              await widget.onEdit!(updatedProduct);
                              ref.invalidate(fetchMyProductsProvider);
                            } else {
                              success = await _addNewProduct();
                              ref.invalidate(fetchMyProductsProvider);
                            }

                            // Clear form
                            productNameController.clear();
                            productDescriptionController.clear();
                            productMoqController.clear();
                            productActualPriceController.clear();
                            productOfferPriceController.clear();
                            productPriceType.clear();
                            setState(() {
                              productImage = null;
                            });
                          } finally {
                            if (success)
                              Navigator.of(context).pop(); // Close loader
                            Navigator.pop(context);
                          }
                        }
                      },
                      fontSize: 16,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> _showProductPriceTypeDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text('Select a Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Kilogram (kg)'),
              onTap: () => Navigator.of(context).pop('kg'),
            ),
            ListTile(
              title: const Text('Gram (g)'),
              onTap: () => Navigator.of(context).pop('g'),
            ),
            ListTile(
              title: const Text('Per Piece'),
              onTap: () => Navigator.of(context).pop('piece'),
            ),
            ListTile(
              title: const Text('Litre (L)'),
              onTap: () => Navigator.of(context).pop('L'),
            ),
          ],
        ),
      );
    },
  );
}
