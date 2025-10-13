import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/chat_manager.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
      ),
      body: Consumer<ChatManager>(
        builder: (context, chatManager, child) {
          if (chatManager.sessions.isEmpty) {
            return const Center(
              child: Text('No chat history found.'),
            );
          }

          return ListView.builder(
            itemCount: chatManager.sessions.length,
            itemBuilder: (context, index) {
              final session = chatManager.sessions[index];
              return ListTile(
                title: Text(session.title),
                subtitle: Text(
                  DateFormat.yMMMd().add_jm().format(session.createdAt),
                ),
                onTap: () {
                  chatManager.setActiveSession(session.id);
                  // Navigate back to the home screen (which will show the chat screen)
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      ),
    );
  }
}
