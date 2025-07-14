import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/product_model.dart';
import 'package:hef/src/interface/components/DropDown/block_repor_dropDown.dart';
import 'package:hef/src/interface/components/DropDown/dropdown_menu.dart';

class ProductCard extends StatelessWidget {
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;
  final Product product;
  final bool? isOthersProduct;
  final bool? statusNeeded;

  const ProductCard(
      {this.onRemove,
      required this.product,
      super.key,
      this.isOthersProduct,
      this.statusNeeded = false,
      required this.onEdit});

  @override
  Widget build(BuildContext context) {
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
                          children: [  if(product.price!=null&&product.price!=''&& product.price!='null')
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
                                  color:
                                      const Color.fromARGB(255, 112, 112, 112),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                        if(product.offerPrice!=null&&product.offerPrice!=''&& product.offerPrice!='null')
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
                      if(product.moq!=null&&product.moq!=''&& product.moq!='null'&&product.moq!=0)
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
}
