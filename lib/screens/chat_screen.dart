import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/chat_manager.dart';
import 'package:simple_app/models/chat_message.dart';
import 'package:simple_app/models/settings_manager.dart';
import 'package:simple_app/services/open_router_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final OpenRouterService _openRouterService = OpenRouterService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start a new session if there isn't one when the screen is first built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatManager = Provider.of<ChatManager>(context, listen: false);
      if (chatManager.activeSession == null) {
        chatManager.startNewSession();
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final chatManager = Provider.of<ChatManager>(context, listen: false);
    final settings = Provider.of<SettingsManager>(context, listen: false);

    // If there's no active session, start one.
    if (chatManager.activeSession == null) {
      chatManager.startNewSession();
    }

    final userMessage = ChatMessage(text: text, isUserMessage: true);
    chatManager.addMessageToActiveSession(userMessage);

    _textController.clear();
    setState(() {
      _isLoading = true;
    });

    final apiKey = settings.openRouterApiKey;
    final modelName = settings.openRouterModelName;

    final response = await _openRouterService.getChatCompletion(
      apiKey: apiKey,
      modelName: modelName,
      userMessage: text,
    );

    final aiMessage = ChatMessage(text: response, isUserMessage: false);
    chatManager.addMessageToActiveSession(aiMessage);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ChatManager>(
        builder: (context, chatManager, child) {
          final messages = chatManager.activeSession?.messages ?? [];

          return Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) {
                    final message = messages[index];
                    return _buildMessageItem(message);
                  },
                  itemCount: messages.length,
                ),
              ),
              if (_isLoading) const LinearProgressIndicator(),
              const Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUserMessage
                    ? Theme.of(context).colorScheme.primary.withAlpha((255 * 0.8).round())
                    : Colors.grey[700],
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading
                    ? null // Disable button while loading
                    : () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
