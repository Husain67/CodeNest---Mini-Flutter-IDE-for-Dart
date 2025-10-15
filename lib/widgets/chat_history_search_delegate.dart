import 'package:flutter/material.dart';

class ChatHistorySearchDelegate extends SearchDelegate {
  final List<String> chatHistoryList;

  ChatHistorySearchDelegate(this.chatHistoryList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results logic here
    return const Center(child: Text('Search results placeholder'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions logic here
    return const Center(child: Text('Search suggestions placeholder'));
  }
}
