import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class WikipediaPage extends StatefulWidget {
  final ThemeData theme;

  const WikipediaPage({Key? key, required this.theme}) : super(key: key);

  @override
  _WikipediaPageState createState() => _WikipediaPageState();
}

class _WikipediaPageState extends State<WikipediaPage> {
  final TextEditingController _searchController = TextEditingController();
  List<WikiResult> _searchResults = [];
  bool _isLoading = false;

  final List<String> defaultAnimals = [
    'Raccoon',
    'American black bear',
    'Bobcat',
    'Coyote',
    'North American river otter',
    'Deer',
    'Raptor',
    'Harbor seal'
  ];

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
      'title': 'Can I Keep the Wild Animal?',
      'author': 'NWRA',
      'content': 'https://www.nwrawildlife.org/page/Can_I_Keep_the_Wild_Animal'
    },
    {
      'title': 'What to Do with Baby Birds',
      'author': 'Chirp for Birds',
      'content': 'https://chirpforbirds.com/how-to/what-to-do-when-you-find-a-baby-bird-on-the-ground/#:~:text=They%20are%20still%20learning%20to,are%E2%80%94without%20need%20of%20rescue.'
    },
    {
      'title': 'Found an Injured Bat?',
      'author': 'Bat Conservation',
      'content': 'https://www.batcon.org/about-bats/found-an-injured-bat/'
    },
  ];


  @override
  void initState() {
    super.initState();
    _loadDefaultAnimals();
  }

  Future<void> _loadDefaultAnimals() async {
    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });

    try {
      final randomAnimals = List<String>.from(defaultAnimals)..shuffle();
      final selectedAnimals = randomAnimals.take(5).toList();

      for (String animal in selectedAnimals) {
        await _searchWikipedia(animal, isDefault: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading suggestions: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchWikipedia(String query, {bool isDefault = false}) async {
    if (query.isEmpty) return;

    if (!isDefault) {
      setState(() {
        _isLoading = true;
        _searchResults.clear();
      });
    }

    try {
      final response = await http.get(Uri.parse(
          'https://en.wikipedia.org/w/api.php?'
          'origin=*'
          '&action=query'
          '&format=json'
          '&prop=pageimages|extracts|info'
          '&generator=search'
          '&gsrsearch=${Uri.encodeComponent(query)}%20animal'
          '&gsrlimit=${isDefault ? 1 : 5}'  
          '&exintro=1'
          '&explaintext=1'
          '&exsentences=2'
          '&piprop=thumbnail'
          '&pithumbsize=100'
          '&inprop=url'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['query'] != null && data['query']['pages'] != null) {
          final pages = data['query']['pages'] as Map<String, dynamic>;
          
          final newResults = pages.values.map((page) => WikiResult(
            title: page['title'] as String,
            extract: page['extract'] as String? ?? 'No description available',
            thumbnailUrl: page['thumbnail']?['source'] as String?,
            fullUrl: page['fullurl'] as String?,
          )).toList();

          setState(() {
            if (isDefault) {
              _searchResults.addAll(newResults);
            } else {
              _searchResults = newResults;
            }
          });
        }
      }
    } catch (e) {
      if (mounted && !isDefault) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching Wikipedia: $e')),
        );
      }
    } finally {
      if (!isDefault) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL is empty or invalid.')),
        );
      }
      return;
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for an animal...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults.clear();
                    });
                    _loadDefaultAnimals();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onSubmitted: (query) => _searchWikipedia(query),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  ..._searchResults.map((result) => ListTile(
                        leading: result.thumbnailUrl != null
                            ? Image.network(
                                result.thumbnailUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.pets),
                        title: Text(result.title),
                        subtitle: Text(result.extract),
                        onTap: () => _launchUrl(result.fullUrl!),
                      )),
                  const Divider(),
                  ...links.map((link) => ListTile(
                        leading: const Icon(Icons.link),
                        title: Text(link['title']?? 'title'),
                        onTap: () => _launchUrl(link['content']),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class WikiResult {
  final String title;
  final String extract;
  final String? thumbnailUrl;
  final String? fullUrl;

  WikiResult({
    required this.title,
    required this.extract,
    this.thumbnailUrl,
    this.fullUrl,
  });
}

class WildlifeLink {
  final String title;
  final String url;

  WildlifeLink({required this.title, required this.url});
}