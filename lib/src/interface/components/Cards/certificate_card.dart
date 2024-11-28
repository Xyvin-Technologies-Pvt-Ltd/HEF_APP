
import 'package:flutter/material.dart';
import 'package:hef/src/data/models/user_model.dart';

class CertificateCard extends StatelessWidget {
  final VoidCallback? onRemove;

  final Link certificate;

  const CertificateCard(
      {required this.onRemove, super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16, left: 10, right: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color.fromARGB(255, 201, 198, 198)),
        ),
        height: 200.0, // Set the desired fixed height for the card
        width: double.infinity, // Ensure the card width fits the screen
        child: Column(
          mainAxisSize:
              MainAxisSize.max, // Make the column take the full height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150.0, // Adjusted height to fit within the 150px card
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                image: DecorationImage(
                  image: NetworkImage(
                      certificate.link!), // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: onRemove != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                certificate.name ?? '',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // Adds "..." if the text is too long
                                maxLines: 1, // Limits to a single line
                              ),
                            ),
                            IconButton(
                              onPressed: () => onRemove!(),
                              icon: Icon(Icons.close),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              certificate.name!,
                              style: const TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}