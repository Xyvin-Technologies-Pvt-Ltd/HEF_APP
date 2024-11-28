import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/color_constants.dart';
import 'package:hef/src/data/models/user_model.dart';

Padding customWebsiteVideoCard({Link? websiteVideo, VoidCallback? onRemove}) {
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
                child: Icon(Icons.language, color: kPrimaryColor),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                '${websiteVideo!.name}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Optional: to limit to one line
                style: TextStyle(fontSize: 16), // Adjust style as needed
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onRemove!(),
            child: Padding(
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
                  child: Icon(Icons.remove, color: kPrimaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
