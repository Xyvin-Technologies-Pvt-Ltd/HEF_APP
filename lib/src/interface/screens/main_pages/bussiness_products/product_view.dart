import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/business_category_model.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/data/notifiers/business_category_notifier.dart';
import 'package:hef/src/data/notifiers/products_notifier.dart';
import 'package:hef/src/data/services/navgitor_service.dart';
import 'package:hef/src/interface/components/Cards/product_card.dart';
import 'package:hef/src/interface/components/ModalSheets/product_details.dart';
import 'package:hef/src/interface/components/common/community_chrome.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';

class ProductView extends ConsumerStatefulWidget {
  const ProductView({super.key});

  @override
  ConsumerState<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<ProductView> {
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _hasSearched = false;
  String? _categoryId;
  String? _categoryName;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(productsNotifierProvider.notifier).fetchMoreProducts();
    });
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
    setState(() => _hasSearched = true);
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(productsNotifierProvider.notifier).searchProducts(query);
    });
  }

  void _onSearchSubmitted(String query) {
    setState(() => _hasSearched = true);
    // Perform search when search is submitted
    ref.read(productsNotifierProvider.notifier).searchProducts(query);
  }

  bool _matchesCategory(Product product, List<Product> source) {
    final selectedName = _categoryName?.trim().toLowerCase();
    final selectedId = _categoryId;
    if ((selectedName == null || selectedName.isEmpty) &&
        (selectedId == null || selectedId.isEmpty)) {
      return true;
    }

    final hasStructuredCategory = source.any(
      (item) =>
          (item.categoryId != null && item.categoryId!.isNotEmpty) ||
          (item.categoryName != null && item.categoryName!.isNotEmpty),
    );
    if (hasStructuredCategory) {
      if (selectedId != null &&
          selectedId.isNotEmpty &&
          product.categoryId == selectedId) {
        return true;
      }
      final productName = product.categoryName?.trim().toLowerCase();
      return selectedName != null &&
          selectedName.isNotEmpty &&
          productName == selectedName;
    }

    if (selectedName == null || selectedName.isEmpty) return true;
    final blob =
        '${product.name ?? ''} ${product.description ?? ''}'.toLowerCase();
    return blob.contains(selectedName);
  }

  void _showFilterSheet() {
    var tempId = _categoryId;
    var tempName = _categoryName;
    ref.read(businessCategoryNotifierProvider.notifier).fetchMoreCategories();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss filter',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return _ProductFilterSheet(
              categoryName: tempName,
              onClear: () {
                setSheetState(() {
                  tempId = null;
                  tempName = null;
                });
              },
              onCancel: () => Navigator.pop(dialogContext),
              onSelectCategory: () async {
                final choice = await showModalBottomSheet<_CategoryChoice>(
                  context: dialogContext,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) =>
                      _ProductCategoryPicker(selectedId: tempId),
                );
                if (!dialogContext.mounted || choice == null) return;
                setSheetState(() {
                  tempId = choice.id;
                  tempName = choice.label;
                });
              },
              onApply: () {
                setState(() {
                  _categoryId = tempId;
                  _categoryName = tempName;
                });
                Navigator.pop(dialogContext);
              },
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: FadeTransition(
                  opacity: curved,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                      child: const ColoredBox(color: Color(0x66000000)),
                    ),
                  ),
                ),
              ),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openModalSheet({required String sheet}) {
    if (sheet == 'product') {
      NavigationService navigationService = NavigationService();
      navigationService.pushNamed('EnterProductsPage');
    }
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
      final productNotifier = ref.read(productsNotifierProvider.notifier);
      final visibleProducts = products
          .where((product) => _matchesCategory(product, products))
          .toList();
      final bottomInset = MediaQuery.paddingOf(context).bottom;
      final categoryFilterActive =
          (_categoryId != null && _categoryId!.isNotEmpty) ||
              (_categoryName != null && _categoryName!.trim().isNotEmpty);

      return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (_searchFocus.hasFocus) {
            _searchFocus.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: 136 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                CommunitySearchRow(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  hint: 'Search products by name and category..',
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                  onFilter: _showFilterSheet,
                  filterActive: true,
                ),
                const SizedBox(height: 14),
                if (visibleProducts.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 13,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 244,
                    ),
                    itemCount: visibleProducts.length,
                    itemBuilder: (context, index) {
                      return Consumer(
                        builder: (context, ref, child) {
                          final productCard = ProductCard(
                            onEdit: null,
                            isOthersProduct: true,
                            marketplaceStyle: true,
                            product: visibleProducts[index],
                            onRemove: null,
                          );
                          final asyncProductOwner = ref.watch(
                              fetchUserDetailsProvider(
                                  visibleProducts[index].seller ?? ''));
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
                                    product: visibleProducts[index]),
                                child: productCard,
                              );
                            },
                            error: (error, stackTrace) => productCard,
                            loading: () => productCard,
                          );
                        },
                      );
                    },
                  )
                else if (productNotifier.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: CircularProgressIndicator(),
                  )
                else if (productNotifier.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48.0),
                    child: Column(
                      children: [
                        Text(
                          'Could not load products: ${productNotifier.errorMessage}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: productNotifier.fetchMoreProducts,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (!_hasSearched && !categoryFilterActive)
                  Column(
                    children: [
                      const SizedBox(height: 100),
                      Image.asset('assets/pngs/searchproduct.png'),
                      const SizedBox(height: 20),
                      Text('No products available',
                          style: kHeadTitleB.copyWith(color: kGreyDark)),
                    ],
                  )
                else
                  const Column(
                    children: [
                      SizedBox(height: 100),
                      Text(
                        'No Products Found',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Material(
              color: kCommunityOrange,
              elevation: 4,
              shadowColor: const Color(0x40FF6D00),
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => _openModalSheet(sheet: 'product'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Add Product/Service',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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

class _CategoryChoice {
  final String id;
  final String label;

  const _CategoryChoice({required this.id, required this.label});
}

class _ProductFilterSheet extends StatelessWidget {
  final String? categoryName;
  final VoidCallback onClear;
  final VoidCallback onCancel;
  final VoidCallback onSelectCategory;
  final VoidCallback onApply;

  const _ProductFilterSheet({
    required this.categoryName,
    required this.onClear,
    required this.onCancel,
    required this.onSelectCategory,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = categoryName != null && categoryName!.trim().isNotEmpty;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB4B9BE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF12141A),
                          height: 1.15,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onClear,
                      style: TextButton.styleFrom(
                        foregroundColor: kCommunityOrange,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Product Category',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF12141A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onSelectCategory,
                    child: SizedBox(
                      height: 52,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business_center_outlined,
                              color: kCommunityOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hasValue
                                    ? categoryName!
                                    : 'Select Product Category',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: hasValue
                                      ? const Color(0xFF12141A)
                                      : const Color(0xFFA0A5AD),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF8B9098),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: onCancel,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFFEEDE6),
                            foregroundColor: kCommunityOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: onApply,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: kCommunityOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCategoryPicker extends ConsumerStatefulWidget {
  final String? selectedId;

  const _ProductCategoryPicker({required this.selectedId});

  @override
  ConsumerState<_ProductCategoryPicker> createState() =>
      _ProductCategoryPickerState();
}

class _ProductCategoryPickerState extends ConsumerState<_ProductCategoryPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(businessCategoryNotifierProvider);
    final loading =
        ref.read(businessCategoryNotifierProvider.notifier).isLoading;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final visible = categories.where((category) {
      if (category.id.isEmpty || category.name.trim().isEmpty) return false;
      if (_query.isEmpty) return true;
      return category.name.toLowerCase().contains(_query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.62,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFB4B9BE),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Product Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF12141A),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search category',
                  hintStyle: const TextStyle(color: Color(0xFFA0A5AD)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFFA0A5AD)),
                  filled: true,
                  fillColor: const Color(0xFFF7F8FA),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kCommunityOrange),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _options(visible, loading && categories.isEmpty)),
          ],
        ),
      ),
    );
  }

  Widget _options(List<BusinessCategoryModel> visible, bool loading) {
    if (loading) return const Center(child: LoadingAnimation());
    if (visible.isEmpty) {
      return const Center(
        child: Text(
          'No categories found',
          style: TextStyle(fontSize: 14, color: Color(0xFF8B93A0)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final option = visible[index];
        final selected = option.id == widget.selectedId;
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            option.name.trim(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? kCommunityOrange : const Color(0xFF12141A),
            ),
          ),
          trailing: selected
              ? const Icon(Icons.check, color: kCommunityOrange, size: 20)
              : null,
          onTap: () => Navigator.pop(
            context,
            _CategoryChoice(id: option.id, label: option.name.trim()),
          ),
        );
      },
    );
  }
}
