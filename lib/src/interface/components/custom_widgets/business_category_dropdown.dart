import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/business_category_model.dart';
import 'package:hef/src/data/notifiers/business_category_notifier.dart';

class BusinessCategoryDropdown extends ConsumerStatefulWidget {
  final BusinessCategoryModel? selectedValue;
  final ValueChanged<BusinessCategoryModel?> onChanged;
  final String? label;
  final String? hintText;
  final String? Function(BusinessCategoryModel?)? validator;
  final bool required;

  const BusinessCategoryDropdown({
    Key? key,
    required this.onChanged,
    this.selectedValue,
    this.label,
    this.hintText,
    this.validator,
    this.required = false,
  }) : super(key: key);

  @override
  ConsumerState<BusinessCategoryDropdown> createState() =>
      _BusinessCategoryDropdownState();
}

class _BusinessCategoryDropdownState
    extends ConsumerState<BusinessCategoryDropdown> {
  final TextEditingController _searchController = TextEditingController();
  BusinessCategoryModel? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedValue;
    // Load initial categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialCategories();
    });
  }

  @override
  void didUpdateWidget(BusinessCategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _selectedCategory = widget.selectedValue;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialCategories() {
    ref.read(businessCategoryNotifierProvider.notifier).fetchMoreCategories();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    // Debounce search to avoid too many API calls
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _searchQuery == query) {
        if (query.isEmpty) {
          ref
              .read(businessCategoryNotifierProvider.notifier)
              .refreshCategories();
        } else {
          ref
              .read(businessCategoryNotifierProvider.notifier)
              .searchCategories(query);
        }
      }
    });
  }

  void _onCategorySelected(BusinessCategoryModel? category) {
    setState(() {
      _selectedCategory = category;
    });
    widget.onChanged(category);
  }

  List<BusinessCategoryModel> _filterCategories(
      List<BusinessCategoryModel> categories) {
    if (_searchQuery.isEmpty) return categories;
    return categories
        .where((category) =>
            category.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final businessCategories = ref.watch(businessCategoryNotifierProvider);
    final notifier = ref.watch(businessCategoryNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        FormField<BusinessCategoryModel>(
          validator: (value) {
            if (widget.required && value == null) {
              return 'Business category is required';
            }
            return widget.validator?.call(value);
          },
          builder: (FormFieldState<BusinessCategoryModel> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => _CategorySelectionSheet(
                        categories: _filterCategories(businessCategories),
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          Navigator.pop(context);
                          _onCategorySelected(category);
                          state.didChange(category);
                        },
                        onSearchChanged: _onSearchChanged,
                        searchQuery: _searchQuery,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: state.hasError ? Colors.red : kGrey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: kWhite,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCategory?.name ??
                                widget.hintText ??
                                'Select business category',
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedCategory != null
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CategorySelectionSheet extends StatelessWidget {
  final List<BusinessCategoryModel> categories;
  final BusinessCategoryModel? selectedCategory;
  final Function(BusinessCategoryModel?) onCategorySelected;
  final Function(String) onSearchChanged;
  final String searchQuery;

  const _CategorySelectionSheet({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onSearchChanged,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Business Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kPrimaryColor),
                    ),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(height: 16),
              // Categories list
              Expanded(
                child: categories.isEmpty
                    ? const Center(
                        child: Text('No categories found'),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected =
                              category.id == selectedCategory?.id;

                          return InkWell(
                            onTap: () => onCategorySelected(category),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? kPrimaryColor.withOpacity(0.1)
                                    : null,
                                border: Border.all(
                                  color: isSelected
                                      ? kPrimaryColor
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? kPrimaryColor
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (category.companyCount != null &&
                                            category.companyCount! > 0)
                                          Text(
                                            '${category.companyCount} companies',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: kPrimaryColor,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
