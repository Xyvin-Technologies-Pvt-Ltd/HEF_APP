import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/user_model.dart';
import 'package:hef/src/interface/components/DropDown/dropdown_menu.dart';
import 'package:hef/src/interface/components/DropDown/remove_edit_dropdown.dart';

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

Padding customWebsiteCard({
  required VoidCallback onRemove,
  required VoidCallback onEdit,
  required Link? website,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 20,
      left: 15,
      right: 15,
    ),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              width: 42,
              height: 42,
              child: Icon(
                Icons.language,
                color: kPrimaryColor,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Text(
                '${website?.name != '' && website?.name != null && website?.name != 'null' ? website?.name : website?.link ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: RemoveEditDropdown(
                onRemove: onRemove,
                onEdit: onEdit,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    ),
  );
}

Padding customVideoCard({
  required VoidCallback onRemove,
  required VoidCallback onEdit,
  required Link? video,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 20,
      left: 15,
      right: 15,
    ),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF2F2F2),
      ),
      child: Row(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            child: Align(
              alignment: Alignment.topCenter,
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                width: 42,
                height: 42,
                child: Icon(
                  FontAwesomeIcons.youtube,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Text(
                video?.name != '' &&
                        video?.name != null &&
                        video?.name != 'null'
                    ? video?.name ?? ''
                    : video?.link ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: RemoveEditDropdown(
                onRemove: onRemove,
                onEdit: onEdit,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    ),
  );
}
