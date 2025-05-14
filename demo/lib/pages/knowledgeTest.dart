import 'package:flutter/material.dart';

/// A page that displays a knowledge test with multiple-choice questions.
///
/// Users can answer each question and submit their responses.
class KnowledgeTestPage extends StatefulWidget {
  const KnowledgeTestPage({Key? key}) : super(key: key);

  @override
  _KnowledgeTestPageState createState() => _KnowledgeTestPageState();
}

///
/// Tracks user selections for each of the three questions
/// and handles the submission of responses.
class _KnowledgeTestPageState extends State<KnowledgeTestPage> {
  String? question1Answer;

  String? question2Answer;

  String? question3Answer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Test'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question 1
            const Text(
              '1. Should we feed injured wildlife overnight?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRadioOptions(
              groupValue: question1Answer,
              onChanged: (value) {
                setState(() {
                  question1Answer = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Question 2
            const Text(
              '2. Are owls raptors?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRadioOptions(
              groupValue: question2Answer,
              onChanged: (value) {
                setState(() {
                  question2Answer = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Question 3
            const Text(
              '3. If I want to control a bird, should I cover its head with a cloth?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildRadioOptions(
              groupValue: question3Answer,
              onChanged: (value) {
                setState(() {
                  question3Answer = value;
                });
              },
            ),
            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSubmit,
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

  /// Builds a column of radio button options for a question.

  Widget _buildRadioOptions({
    required String? groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('Yes'),
          value: 'yes',
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        RadioListTile<String>(
          title: const Text('No'),
          value: 'no',
          groupValue: groupValue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  /// Handles the submission of the test responses.
  ///
  /// Prints the selected answers for each question to the console.
  void _handleSubmit() {
    print(
        'Q1: ${question1Answer ?? "No answer"}, Q2: ${question2Answer ?? "No answer"}, Q3: ${question3Answer ?? "No answer"}');
    // Here you can add further logic, such as validating answers or sending them to a server.
  }
}
