import 'package:flutter/foundation.dart';
import 'package:simple_app/models/chat_message.dart';
import 'package:uuid/uuid.dart';

// Represents a single, continuous chat conversation.
class ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  ChatSession({required this.id, required this.title, required this.messages, required this.createdAt});
}

class ChatManager extends ChangeNotifier {
  final List<ChatSession> _sessions = [];
  String? _activeSessionId;
  final Uuid _uuid = const Uuid();

  List<ChatSession> get sessions => _sessions;
  ChatSession? get activeSession {
    if (_activeSessionId == null) return null;
    return _sessions.firstWhere((s) => s.id == _activeSessionId);
  }

  // Starts a new chat session and sets it as the active one.
  void startNewSession() {
    final newSession = ChatSession(
      id: _uuid.v4(),
      title: 'New Chat',
      messages: [],
      createdAt: DateTime.now(),
    );
    _sessions.insert(0, newSession); // Add to the top of the list
    _activeSessionId = newSession.id;
    notifyListeners();
  }

  // Adds a message to the currently active session.
  void addMessageToActiveSession(ChatMessage message) {
    if (activeSession != null) {
      activeSession!.messages.insert(0, message); // Insert at the beginning for reverse list view

      // If this is the first user message, set the title
      if (activeSession!.messages.length == 2 && message.isUserMessage) {
        activeSession!.title = message.text.length > 30
            ? '${message.text.substring(0, 30)}...'
            : message.text;
      }

      notifyListeners();
    }
  }

  // Sets a session as the active one.
  void setActiveSession(String sessionId) {
    _activeSessionId = sessionId;
    notifyListeners();
  }
}
