import 'package:flutter/material.dart';

class MemberCreationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Creation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const CustomTextField(label: 'Full Name', hintText: 'Enter full name'),
            const CustomTextField(label: 'Blood Group', hintText: 'Blood Group'),
            const UploadPhotoWidget(),
            const CustomTextField(label: 'Bio', hintText: 'Add description', maxLines: 5),
            const CustomTextField(label: 'Email ID', hintText: 'Email ID'),
            const CustomPhoneField(),
            const CustomTextField(label: 'Personal Address', hintText: 'Personal Address'),
            const CustomTextField(label: 'Company Name', hintText: 'Name'),
            const CustomTextField(label: 'Company Phone', hintText: 'Number'),
            const CustomTextField(label: 'Designation', hintText: 'Designation'),
            const CustomTextField(label: 'Company Email', hintText: 'email'),
            const CustomTextField(label: 'Website', hintText: 'Link'),
            const CustomDropdown(label: 'Business Category'),
            const CustomDropdown(label: 'Sub category'),
            const CustomDropdown(label: 'Status', items: ['Active', 'Inactive']),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final int maxLines;

  const CustomTextField({
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(),
            ),
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;

  const CustomDropdown({
    required this.label,
    this.items = const ['Option 1', 'Option 2', 'Option 3'],
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {},
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class UploadPhotoWidget extends StatelessWidget {
  const UploadPhotoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Photo', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.upload, size: 40, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPhoneField extends StatelessWidget {
  const CustomPhoneField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('+ Add another'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
