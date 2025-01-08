import 'dart:developer';
import 'dart:io';
import 'package:hef/src/data/api_routes/products_api/products_api.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/interface/components/Buttons/primary_button.dart';
import 'package:hef/src/interface/components/custom_widgets/custom_textFormField.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/edit_user.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/data/services/image_upload.dart';
import 'package:path/path.dart';

class EnterProductsPage extends ConsumerStatefulWidget {
  EnterProductsPage({
    super.key,
  });

  @override
  ConsumerState<EnterProductsPage> createState() => _EnterProductsPageState();
}

class _EnterProductsPageState extends ConsumerState<EnterProductsPage> {
  File? productImage;

  final _formKey = GlobalKey<FormState>();
  TextEditingController productPriceType =
      TextEditingController(text: "Price per unit");
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

  Future<File?> _pickFile({required String imageType}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
    );

    if (result != null) {
      // Check if the file size is more than or equal to 1 MB (1 MB = 1024 * 1024 bytes)
      // if (result.files.single.size >= 1024 * 1024) {
      //   CustomSnackbar.showSnackbar(context, 'File size cannot exceed 1MB');

      //   return null; // Exit the function if the file is too large
      // }

      // Set the selected file if it's within the size limit and matches the specified image type
      if (imageType == 'product') {
        _productImageFIle = File(result.files.single.path!);
        return _productImageFIle;
      }
    }

    return null;
  }

  Future<void> _addNewProduct() async {
    productUrl = await imageUpload(
      basename(_productImageFIle!.path),
      _productImageFIle!.path,
    );
    log('product price type:${productPriceType.text}');
    final createdProduct = await uploadProduct(
      name: productNameController.text,
      price: productActualPriceController.text,
      offerPrice: productOfferPriceController.text,
      description: productDescriptionController.text,
      moq: productMoqController.text,
      productImage: productUrl,
      productPriceType: productPriceType.text,
    );
    if (createdProduct == null) {
      print('couldnt create new product');
    } else {
      final newProduct = Product(
        id: createdProduct.id,
        name: productNameController.text,
        image: productUrl,
        description: productDescriptionController.text,
        moq: int.parse(productMoqController.text),
        offerPrice: double.parse(productOfferPriceController.text),
        price: double.parse(productActualPriceController.text),
        seller: id,
        status: 'pending',
      );
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
                  child: Image.asset(
                    'assets/pngs/hef_logo.png',
                    fit: BoxFit.contain,
                  ),
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
                            'Add Product',
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
                          return 'Please upload an image';
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
                                    ? const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add,
                                                size: 27, color: kPrimaryColor),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 10,
                    ),
                    const SizedBox(height: 10),
                    ModalSheetTextFormField(
                      textInputType: TextInputType.number,
                      textController: productMoqController,
                      label: 'Add MOQ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the MOQ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: ModalSheetTextFormField(
                            textInputType: TextInputType.number,
                            textController: productActualPriceController,
                            label: 'Actual price',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the actual price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: ModalSheetTextFormField(
                            textInputType: TextInputType.number,
                            textController: productOfferPriceController,
                            label: 'Offer price',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the offer price';
                              }
                              if (int.parse(productOfferPriceController.text) >
                                  int.parse(
                                      productActualPriceController.text)) {
                                return 'Make actual price higher';
                              }
                              if (int.parse(
                                      productActualPriceController.text) ==
                                  int.parse(productOfferPriceController.text)) {
                                return 'Prices should be different';
                              }
                              return null;
                            },
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
                      label: 'SAVE',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) =>
                                const Center(child: LoadingAnimation()),
                          );

                          try {
                            await _addNewProduct();
                            productActualPriceController.clear();
                            productDescriptionController.clear();
                            productMoqController.clear();
                            productOfferPriceController.clear();
                            productNameController.clear();
                            productPriceType.clear();

                            if (productImage != null) {
                              setState(() {
                                productImage = null;
                              });
                            }

                            ref.invalidate(fetchMyProductsProvider);
                          } finally {
                            Navigator.of(context).pop(); // Close loader
                            Navigator.pop(context); // Go back
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
              onTap: () {
                Navigator.of(context).pop('kg');
              },
            ),
            ListTile(
              title: const Text('Gram (g)'),
              onTap: () {
                Navigator.of(context).pop('g');
              },
            ),
            ListTile(
              title: const Text('Per Piece'),
              onTap: () {
                Navigator.of(context).pop('piece');
              },
            ),
            ListTile(
              title: const Text('Litre (L)'),
              onTap: () {
                Navigator.of(context).pop('L');
              },
            ),
          ],
        ),
      );
    },
  );
}
