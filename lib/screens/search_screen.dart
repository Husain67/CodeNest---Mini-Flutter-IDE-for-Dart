import 'dart:async';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/file_manager.dart';
import 'package:simple_app/models/file_model.dart';
import 'package:simple_app/models/settings_manager.dart';
import 'package:simple_app/screens/editor_screen.dart';

// Enums for search
enum SearchFilter { symbol, file, comment, string, error, widget, importStatement }
enum SearchScope { currentFile, project, folder }

// Data class for a search result
class SearchResult {
  final FileModel file;
  final int lineNumber;
  final String lineContent;
  final String matchedText;

  SearchResult({
    required this.file,
    required this.lineNumber,
    required this.lineContent,
    required this.matchedText,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  // Search options
  final Set<SearchFilter> _selectedFilters = {SearchFilter.file}; // Default to file content
  SearchScope _selectedScope = SearchScope.project;
  bool _isCaseSensitive = false;
  bool _isRegex = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _performSearch(_searchController.text);
      });
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    final fileManager = Provider.of<FileManager>(context, listen: false);
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);
    final allFiles = fileManager.savedFiles;
    final List<SearchResult> results = [];

    // Search in console errors if the filter is active
    if (_selectedFilters.contains(SearchFilter.error) && settingsManager.lastConsoleOutput.toLowerCase().contains(query.toLowerCase())) {
        results.add(SearchResult(
            file: FileModel(name: 'Console Error', type: 'Log', createdDate: DateTime.now()),
            lineNumber: 1,
            lineContent: settingsManager.lastConsoleOutput,
            matchedText: query,
        ));
    }

    // This is a simplified search. A full implementation would be more complex.
    for (final file in allFiles) {
      final visitor = _CodeVisitor(
        query: query,
        filters: _selectedFilters,
        isCaseSensitive: _isCaseSensitive,
      );
      try {
        final result = parseString(content: file.content, throwIfDiagnostics: false);
        result.unit.visitChildren(visitor);
        results.addAll(visitor.results.map((r) => SearchResult(
              file: file,
              lineNumber: result.lineInfo.getLocation(r.offset).lineNumber,
              lineContent: result.content.split('\n')[result.lineInfo.getLocation(r.offset).lineNumber - 1].trim(),
              matchedText: r.toSource(),
            )));
      } catch (e) {
        // Fallback for non-dart files or parse errors
        if (_selectedFilters.contains(SearchFilter.file)) {
            if (file.content.toLowerCase().contains(query.toLowerCase())) {
                 results.add(SearchResult(file: file, lineNumber: 1, lineContent: file.content, matchedText: query));
            }
        }
      }
    }

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // UI Code from previous step goes here, updated to use _searchResults
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          // All the UI controls from the previous step...
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search code, comments, errors...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              spacing: 8.0,
              children: SearchFilter.values.map((filter) =>
                FilterChip(
                  label: Text(filter.name),
                  selected: _selectedFilters.contains(filter),
                  onSelected: (selected) => setState(() {
                    if (selected) _selectedFilters.add(filter);
                    else _selectedFilters.remove(filter);
                    _performSearch(_searchController.text);
                  }),
                )
              ).toList(),
            ),
          ),
          const Divider(),
          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(child: Text(_searchController.text.isEmpty ? 'Enter a search term.' : 'No results found.'))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.code),
                            title: Text('${result.file.name}:${result.lineNumber}'),
                            subtitle: Text(result.lineContent),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EditorScreen(
                                    file: result.file,
                                  ),
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
    _debounce?.cancel();
    super.dispose();
  }
}

// AST Visitor to find nodes based on filters
class _CodeVisitor extends GeneralizingAstVisitor<void> {
  final String query;
  final Set<SearchFilter> filters;
  final bool isCaseSensitive;
  final List<AstNode> results = [];

  _CodeVisitor({required this.query, required this.filters, required this.isCaseSensitive});

  @override
  void visitNode(AstNode node) {
    bool matches = false;
    final nodeString = node.toSource();
    final comparisonString = isCaseSensitive ? nodeString : nodeString.toLowerCase();
    final comparisonQuery = isCaseSensitive ? query : query.toLowerCase();

    if (comparisonString.contains(comparisonQuery)) {
        if (filters.contains(SearchFilter.file)) matches = true;
        if (filters.contains(SearchFilter.symbol) && (node is SimpleIdentifier || node is Declaration)) matches = true;
        if (filters.contains(SearchFilter.comment) && node is Comment) matches = true;
        if (filters.contains(SearchFilter.string) && node is StringLiteral) matches = true;
        if (filters.contains(SearchFilter.importStatement) && node is ImportDirective) matches = true;
    }

    if (matches) {
      results.add(node);
    }
    super.visitNode(node);
  }
}