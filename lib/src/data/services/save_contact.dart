import 'package:contact_add/contact.dart';
import 'package:contact_add/contact_add.dart';
import 'package:flutter/material.dart';
import 'package:hef/src/data/services/snackbar_service.dart';

Future<void> saveContact(
    {required String number,
    required String firstName,

    required String email,
    required BuildContext context}) async {
  SnackbarService snackbarService = SnackbarService();
  // Request permission to access contacts
    final Contact contact = Contact(
        firstname: firstName, lastname: '', phone: number, email: email);

    final bool success = await ContactAdd.addContact(contact);

    if (success) {
      snackbarService.showSnackBar('Contact saved successfully!');
    } else {
        snackbarService.showSnackBar('Contact saving failed!');
    }
  
}
