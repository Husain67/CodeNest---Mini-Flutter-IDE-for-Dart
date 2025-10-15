import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:simple_app/models/chat_manager.dart';
import 'package:simple_app/models/chat_message.dart';
import 'package:simple_app/models/settings_manager.dart';
import 'package:simple_app/services/open_router_service.dart';
import 'package:simple_app/widgets/chat_history_search_delegate.dart';
import 'package:simple_app/screens/about_page.dart';
import 'package:simple_app/screens/settings_page.dart';


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
    final settingsManager = Provider.of<SettingsManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("appTitle".tr(), style: GoogleFonts.poppins(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewTab,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _openHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _attachFile,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, context),
            itemBuilder: (context) => [
              PopupMenuItem(value: "about", child: Text("about".tr())),
              PopupMenuItem(value: "security", child: Text("security".tr())),
              PopupMenuItem(value: "dark", child: Text("darkMode".tr())),
              PopupMenuItem(value: "night", child: Text("nightMode".tr())),
              PopupMenuItem(value: "eye", child: Text("eyeMode".tr())),
              PopupMenuItem(value: "language", child: Text("language".tr())),
              PopupMenuItem(value: "settings", child: Text("settings".tr())),
            ],
          ),
        ],
      ),
      body: Consumer<ChatManager>(
        builder: (context, chatManager, child) {
          final messages = chatManager.activeSession?.messages ?? [];
          final bool eyeProtection = settingsManager.eyeProtection;

          return Container(
            color: eyeProtection ? Colors.yellow.withOpacity(0.1) : null,
            child: Column(
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
            ),
          );
        },
      ),
    );
  }

  // --- Menu Bar Logic ---

  void _openSearchDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> chatHistoryList = prefs.getStringList('chatHistory') ?? [];
    await showSearch(
      context: context,
      delegate: ChatHistorySearchDelegate(chatHistoryList),
    );
  }

  void _createNewTab() {
    Provider.of<ChatManager>(context, listen: false).startNewSession();
  }

  void _openHistory(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('chatHistory');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("history".tr()),
        content: SizedBox(
          width: 300,
          child: ListView(
            children: history?.map((msg) => Text(msg)).toList() ?? [const Text("No history yet.")],
          ),
        ),
      ),
    );
  }

  Future<void> _attachFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = result.files.single;
      // For now, just show a snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected file: ${file.name}")),
      );
    }
  }

  void _changeLanguage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("language".tr()),
        content: SizedBox(
          width: 300,
          height: 400,
          child: ListView.builder(
            itemCount: context.supportedLocales.length,
            itemBuilder: (ctx, i) {
              final locale = context.supportedLocales[i];
              return ListTile(
                title: Text(locale.languageCode.toUpperCase()),
                onTap: () {
                  context.setLocale(locale);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context, listen: false);
    switch (value) {
      case "about":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
        break;
      case "security":
        _showSecurityDialog(context);
        break;
      case "dark":
        settingsManager.setThemeMode(ThemeMode.dark);
        break;
      case "night":
        settingsManager.setThemeMode(ThemeMode.light);
        break;
      case "eye":
        settingsManager.toggleEyeProtection();
        break;
      case "language":
        _changeLanguage(context);
        break;
      case "settings":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
        break;
    }
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("security".tr()),
        content: const TextField(
          obscureText: true,
          decoration: InputDecoration(labelText: "Enter PIN"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Save"))
        ],
      ),
    );
  }

  // --- Original Widget Build Methods ---

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
                    ? null
                    : () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
