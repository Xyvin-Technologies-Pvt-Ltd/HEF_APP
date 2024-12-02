import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/user_model.dart';

Padding customWebsiteVideoCard({Link? websiteVideo, VoidCallback? onRemove}) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 20,
      left: 15,
      right: 15,
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: kGrey),
              borderRadius: BorderRadius.circular(10),
              color: kWhite,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Text(
                '${websiteVideo!.name}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Optional: to limit to one line
                style: TextStyle(fontSize: 16), // Adjust style as needed
              ),
            ),
          ),
        ),
        const SizedBox(width: 10), // Optional spacing between items
        InkWell(
          onTap: () => onRemove!(),
          child: SvgPicture.asset('assets/svg/icons/delete_account.svg'),
        ),
      ],
    ),
  );
}
