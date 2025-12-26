import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/business_category_model.dart';
import 'package:hef/src/data/notifiers/business_category_notifier.dart';

class SimpleBusinessCategoryDropdown extends ConsumerStatefulWidget {
  final BusinessCategoryModel? selectedValue;
  final ValueChanged<BusinessCategoryModel?> onChanged;
  final String? label;
  final String? hintText;
  final String? Function(BusinessCategoryModel?)? validator;
  final bool required;

  const SimpleBusinessCategoryDropdown({
    Key? key,
    required this.onChanged,
    this.selectedValue,
    this.label,
    this.hintText,
    this.validator,
    this.required = false,
  }) : super(key: key);

  @override
  ConsumerState<SimpleBusinessCategoryDropdown> createState() =>
      _SimpleBusinessCategoryDropdownState();
}

class _SimpleBusinessCategoryDropdownState
    extends ConsumerState<SimpleBusinessCategoryDropdown> {
  final TextEditingController _searchController = TextEditingController();
  BusinessCategoryModel? _selectedCategory;
  String _searchQuery = '';
  final LayerLink _layerLink = LayerLink();

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
  void didUpdateWidget(SimpleBusinessCategoryDropdown oldWidget) {
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
    final notifier = ref.read(businessCategoryNotifierProvider.notifier);

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
            return CompositedTransformTarget(
              link: _layerLink,
              child: InkWell(
                onTap: () {
                  _showDropdownMenu(state);
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
            );
          },
        ),
      ],
    );
  }

  void _showDropdownMenu(FormFieldState<BusinessCategoryModel> state) {
    final businessCategories = ref.watch(businessCategoryNotifierProvider);
    final filteredCategories = _filterCategories(businessCategories);

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu<BusinessCategoryModel>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        offset.dy + size.height + 200,
      ),
      items: filteredCategories.map((category) {
        return PopupMenuItem<BusinessCategoryModel>(
          value: category,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (category.companyCount != null && category.companyCount! > 0)
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
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        _onCategorySelected(value);
        state.didChange(value);
      }
    });
  }
}
