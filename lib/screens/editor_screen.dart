import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/models/file_model.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';

// TODO: Insert your own paiza.io API key here.
// You can get a free key from the paiza.io website.
// Using 'guest' is for demonstration only and may be unreliable.
const String paizaApiKey = 'guest'; // Replace 'guest' with your actual key.

class EditorScreen extends StatefulWidget {
  final FileModel file;

  const EditorScreen({super.key, required this.file});

  @override
  EditorScreenState createState() => EditorScreenState();
}

class EditorScreenState extends State<EditorScreen> {
  late CodeController _codeController;
  String _output = '';
  bool _isLoading = false;

  final List<String> _dartKeywords = const [
    'abstract', 'else', 'import', 'super', 'as', 'enum', 'in', 'switch',
    'assert', 'export', 'interface', 'sync', 'async', 'extends', 'is', 'this',
    'await', 'extension', 'library', 'throw', 'break', 'external', 'mixin',
    'true', 'case', 'factory', 'new', 'try', 'catch', 'false', 'null', 'typedef',
    'class', 'final', 'on', 'var', 'const', 'finally', 'operator', 'void',
    'continue', 'for', 'part', 'while', 'covariant', 'Function', 'rethrow',
    'with', 'default', 'get', 'return', 'yield', 'deferred', 'hide', 'set',
    'do', 'if', 'show', 'static', 'dynamic', 'implements', 'async*', 'yield*',
    'int', 'double', 'String', 'bool', 'List', 'Map', 'Set', 'Runes', 'Symbol',
    'print'
  ];

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.file.content,
      language: dart,
      analyzer: DartPadAnalyzer(),
    );

    _codeController.autocompleter.setCustomWords(_dartKeywords);

    _codeController.addListener(() {
      widget.file.content = _codeController.text;
    });
  }

  Future<void> _runCode() async {
    if (_isLoading) return;

    if (paizaApiKey == 'guest' || paizaApiKey.isEmpty) {
      setState(() {
        _output = 'Error: API Key is not set.\nPlease set your paiza.io API key in editor_screen.dart';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _output = 'Executing code...';
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.paiza.io/runners/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'source_code': _codeController.text,
          'language': 'dart',
          'api_key': paizaApiKey,
        }),
      );

      if (response.statusCode == 200) {
        final id = jsonDecode(response.body)['id'];
        await _getExecutionDetails(id);
      } else {
        setState(() {
          _output = 'Error creating runner: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _output = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getExecutionDetails(String id) async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final response = await http.get(
        Uri.parse('https://api.paiza.io/runners/get_details?id=$id&api_key=$paizaApiKey'),
      );
      if (response.statusCode == 200) {
        final details = jsonDecode(response.body);
        String result = '';
        if (details['stdout'] != null && details['stdout'].isNotEmpty) {
          result += 'Output:\n${details['stdout']}';
        }
        if (details['stderr'] != null && details['stderr'].isNotEmpty) {
          result += 'Error:\n${details['stderr']}';
        }
        if (details['build_stderr'] != null && details['build_stderr'].isNotEmpty) {
          result += 'Build Error:\n${details['build_stderr']}';
        }
        setState(() {
          _output = result.isEmpty ? 'Execution finished with no output.' : result;
        });
      } else {
        setState(() {
          _output = 'Error getting details: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _output = 'An error occurred while fetching details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.file.name),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow),
            onPressed: _runCode,
          ),
        ],
      ),
      body: Column(
        children: [
          // Code Editor
          Expanded(
            flex: 3,
            child: CodeTheme(
              data: CodeThemeData(styles: monokaiSublimeTheme),
              child: SingleChildScrollView(
                child: CodeField(
                  controller: _codeController,
                  minLines: 10,
                ),
              ),
            ),
          ),
          // Console Output
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Console',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _output,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}