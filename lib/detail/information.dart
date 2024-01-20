import 'package:flutter/material.dart';
import 'package:web_scraper/web_scraper.dart';

class BingSearch extends StatefulWidget {
  @override
  _BingSearchState createState() => _BingSearchState();
}

class _BingSearchState extends State<BingSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> elements = [];
  bool _isloading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> performWebScraping() async {
    

    final String searchQuery = _searchController.text;
    final webScraper = WebScraper('https://www.bing.com');
    elements.clear();

    if (await webScraper.loadWebPage('/search?q=$searchQuery')) {
      elements = webScraper.getElement('.b_algo', []).map((element) {
        final title = element['title'];
        final link = element['href'];

        return {'title': title, 'link': link};
      }).toList();
    } else {
      print('Failed to load Bing search results page.');
    }

    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                hintText: 'Search something...',
                labelText: 'Search something...',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isloading=true;
                performWebScraping();
                });
              },
              child: Text('Search'),
            ),
            if(_isloading)
                CircularProgressIndicator(),
            if (elements.isNotEmpty)
              _isloading
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: elements.length,
                        itemBuilder: (context, index) {
                          final result = elements[index];
                          return ListTile(
                            title: Text(result['title'] ?? ''),
                            subtitle: Text(result['link'] ?? ''),
                          );
                        },
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}