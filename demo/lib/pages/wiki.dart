

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WikipediaPage extends StatelessWidget {
  final ThemeData theme;

  WikipediaPage({required this.theme});

  final List<Map<String, String>> links = [
    {
      'title': 'PAWS Wildlife',
      'author': 'PAWS',
      'content': 'https://www.paws.org/wildlife'
    },
    {
      'title': 'Wildlife Rehabilitation',
      'author': 'WDFW',
      'content': 'https://wdfw.wa.gov/species-habitats/living/injured-wildlife/rehabilitation/find'
    },
    {
      'title': 'Sarvey Wildlife',
      'author': 'Sarvey',
      'content': 'https://www.sarveywildlife.org/'
    },
    {
      'title': 'Found a Wild Animal',
      'author': 'PAWS',
      'content': 'https://www.paws.org/wildlife/found-a-wild-animal/'
    },
    {
      'title': 'What to Do with Baby Birds',
      'author': 'Chirp for Birds',
      'content': 'https://chirpforbirds.com/how-to/what-to-do-when-you-find-a-baby-bird-on-the-ground/#:~:text=They%20are%20still%20learning%20to,are%E2%80%94without%20need%20of%20rescue.'
    },
    {
      'title': 'Can I Keep the Wild Animal?',
      'author': 'NWRA',
      'content': 'https://www.nwrawildlife.org/page/Can_I_Keep_the_Wild_Animal'
    },
    {
      'title': 'Found an Injured Bat?',
      'author': 'Bat Conservation',
      'content': 'https://www.batcon.org/about-bats/found-an-injured-bat/'
    },
  ];

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wikipedia Links'),
      ),
      body: ListView.builder(
        itemCount: links.length,
        itemBuilder: (context, index) {
          final link = links[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 2,
              child: ListTile(
                title: Text(
                  link['title'] ?? 'Unknown Title',
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(link['author'] ?? 'Unknown Author'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () => _launchURL(link['content'] ?? ''),
              ),
            ),
          );
        },
      ),
    );
  }
}