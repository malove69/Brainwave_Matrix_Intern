import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'Profile_page .dart' show ProfilePage;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _name = 'John Doe';
  String _imagePath = 'https://via.placeholder.com/150';
  String _font = 'Roboto';
  bool _isDarkMode = false;

  void _updateProfile(String name, String imagePath, String font) {
    setState(() {
      _name = name;
      _imagePath = imagePath;
      _font = font;
    });
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter News App',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: NewsHomePage(
        name: _name,
        imagePath: _imagePath,
        font: _font,
        onProfileUpdated: _updateProfile,
        onToggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  final String name;
  final String imagePath;
  final String font;
  final bool isDarkMode;
  final Function(String, String, String) onProfileUpdated;
  final Function(bool) onToggleTheme;

  const NewsHomePage({
    super.key,
    required this.name,
    required this.imagePath,
    required this.font,
    required this.onProfileUpdated,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  List<dynamic> _articles = [];
  Set<String> _bookmarkedTitles = {};
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  final String _apiKey = 'f6ff0ce89d654ca09709d6ad074e19c7';

  @override
  void initState() {
    super.initState();
    fetchTopHeadlines();
    loadBookmarks();
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query.isEmpty) {
        fetchTopHeadlines();
      } else {
        searchArticles(query);
      }
    });
  }

  Future<void> fetchTopHeadlines() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _articles = data['articles'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load top headlines');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load news: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> searchArticles(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = 'https://newsapi.org/v2/everything?q=$query&sortBy=publishedAt&language=en&apiKey=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _articles = data['articles'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Search error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarked_titles') ?? [];
    setState(() {
      _bookmarkedTitles = saved.toSet();
    });
  }

  Future<void> toggleBookmark(String title) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedTitles.contains(title)) {
        _bookmarkedTitles.remove(title);
      } else {
        _bookmarkedTitles.add(title);
      }
    });
    await prefs.setStringList('bookmarked_titles', _bookmarkedTitles.toList());
  }

  void _openProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          initialName: widget.name,
          initialImageUrl: widget.imagePath,
          initialFont: widget.font,
          onProfileUpdated: widget.onProfileUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider profileImage;
    if (widget.imagePath.startsWith('http')) {
      profileImage = NetworkImage(widget.imagePath);
    } else {
      profileImage = FileImage(File(widget.imagePath));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: profileImage, radius: 16),
            const SizedBox(width: 10),
            Text(widget.name, style: TextStyle(fontFamily: widget.font)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: _openProfilePage),
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onToggleTheme,
            activeColor: Colors.amber,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search latest news...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    final title = article['title'] ?? 'No Title';
                    final isBookmarked = _bookmarkedTitles.contains(title);

                    return Card(
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: article['urlToImage'] ?? '',
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(title, style: TextStyle(fontFamily: widget.font)),
                        subtitle: Text(article['description'] ?? 'No Description'),
                        trailing: IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? Colors.deepPurple : null,
                          ),
                          onPressed: () => toggleBookmark(title),
                        ),
                      ),
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
