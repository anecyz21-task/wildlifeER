import 'package:flutter/material.dart';

/// A page that allows users to identify themselves as a Volunteer, Professional,
/// or Governmental Official by uploading a verification document, and attest to the
/// accuracy of their information.
class IdentificationPage extends StatelessWidget {
  const IdentificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer/Professional Identification'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Identification Options
            const Text(
              '1. Choose the option that matches you the best',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                RadioListTile(
                  title: const Text('Current Wildlife Organization Volunteer'),
                  value: 'volunteer',
                  groupValue: null,
                  onChanged: (value) {
                  },
                ),

                RadioListTile(
                  title: const Text('Wildlife Professional'),
                  value: 'professional',
                  groupValue: null, 
                  onChanged: (value) {
                  },
                ),


                RadioListTile(
                  title: const Text('Governmental Official'),
                  value: 'official',
                  groupValue: null, 
                  onChanged: (value) {
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 2: Document Upload
            const Text(
              '2. Please upload a document that can verify your identity as one of the mentioned roles.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                // Implement document upload logic
              },
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 3: Attestation
            const Text(
              '3. Attestation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            CheckboxListTile(
              title: const Text(
                  'I certify that all information submitted on any form in this request is accurate and true.'),
              value: false, 
              onChanged: (value) {

              },
            ),
            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                },
                child: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
