import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/file_manager.dart';
import 'package:simple_app/models/file_model.dart';
import 'package:simple_app/screens/editor_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FileModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Start with an empty list
    _searchResults = [];
  }

  void _performSearch(String query) {
    final fileManager = Provider.of<FileManager>(context, listen: false);
    final allFiles = fileManager.savedFiles;

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    final results = allFiles.where((file) {
      final fileNameMatches = file.name.toLowerCase().contains(lowerCaseQuery);
      final fileContentMatches = file.content.toLowerCase().contains(lowerCaseQuery);
      return fileNameMatches || fileContentMatches;
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Files'),
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search by name or content...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Enter a term to start searching.'
                          : 'No results found.',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final file = _searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(file.name),
                        subtitle: Text(
                          file.content.length > 100
                              ? '${file.content.substring(0, 100)}...'
                              : file.content,
                          style: const TextStyle(color: Colors.white60),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditorScreen(file: file),
                            ),
                          );
                        },
                      );
                    },
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