import 'package:flutter/material.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/interface/components/DropDown/block_repor_dropDown.dart';
import 'package:hef/src/interface/components/DropDown/dropdown_menu.dart';
import 'package:hef/src/interface/components/common/community_chrome.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;
  final Product product;
  final bool? isOthersProduct;
  final bool? statusNeeded;
  final bool marketplaceStyle;

  const ProductCard(
      {this.onRemove,
      required this.product,
      super.key,
      this.isOthersProduct,
      this.statusNeeded = false,
      this.marketplaceStyle = false,
      required this.onEdit});

  String _inr(double? value) {
    if (value == null) return '';
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    if (marketplaceStyle) return _marketplaceCard();
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: statusNeeded == true ? 105.0 : 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(product.image!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
              ),
              Container(
                height: statusNeeded == true ? 92 : 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                  color: const Color(0xFFF2F2F2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            if (product.price != null &&
                                product.price != '' &&
                                product.price != 'null')
                              Flexible(
                                child: Text(
                                  '₹ ${product.price}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    decoration: product.offerPrice != null
                                        ? TextDecoration.lineThrough
                                        : null,
                                    fontSize: 15.0,
                                    color: const Color.fromARGB(
                                        255, 112, 112, 112),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(
                              width: 8,
                            ),
                            if (product.offerPrice != null &&
                                product.offerPrice != '' &&
                                product.offerPrice != 'null')
                              Flexible(
                                child: Text(
                                  '₹ ${product.offerPrice}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF004797),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (product.moq != null && product.moq != 0)
                        Text(
                          'MOQ: ${product.moq}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (statusNeeded ?? false)
                        Text(
                          'Status: ${product.status}',
                          style: TextStyle(
                            color: product.status == 'accepted'
                                ? Colors.green
                                : Colors.grey,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (onRemove != null)
            Positioned(
              top: 4.0,
              right: 10.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: DropDownMenu(
                    onRemove: onRemove!,
                    onEdit: onEdit!,
                  ),
                ),
              ),
            ),
          if (isOthersProduct ?? false)
            Positioned(
              top: 4.0,
              right: 10.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: BlockReportDropdown(
                      product: product,
                      isBlocked: false,
                    )),
              ),
            ),
        ],
      ),
    );
  }

  Widget _marketplaceCard() {
    final hasOffer = product.offerPrice != null &&
        product.offerPrice != 0 &&
        product.offerPrice != product.price;
    final description = product.description?.trim();
    final showDescription = description != null &&
        description.isNotEmpty &&
        description != 'null';

    const priceBlue = Color(0xFF1E78B0);
    const struckPrice = Color(0xFFA7A8AD);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F1F4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 124,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: product.image == null || product.image!.isEmpty
                      ? const ColoredBox(color: Color(0xFFF3F4F6))
                      : Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const ColoredBox(color: Color(0xFFF3F4F6)),
                        ),
                ),
                if (isOthersProduct ?? false)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlockReportDropdown(
                      product: product,
                      isBlocked: false,
                      compact: true,
                    ),
                  ),
                if (onRemove != null && onEdit != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: DropDownMenu(onRemove: onRemove!, onEdit: onEdit!),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D24),
                  ),
                ),
                if (showDescription) ...[
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: Color(0xFF8E949E),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (product.price != null)
                      Flexible(
                        child: Text(
                          _inr(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.15,
                            color: hasOffer ? struckPrice : priceBlue,
                            fontWeight: FontWeight.w600,
                            decoration: hasOffer
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: struckPrice,
                          ),
                        ),
                      ),
                    if (hasOffer) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _inr(product.offerPrice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: priceBlue,
                            fontSize: 13.5,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (product.moq != null && product.moq != 0) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFE0C4)),
                    ),
                    child: Text(
                      'MOQ: ${product.moq}',
                      style: const TextStyle(
                        color: kCommunityOrange,
                        fontSize: 11,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
