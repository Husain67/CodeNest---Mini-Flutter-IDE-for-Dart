import 'dart:convert';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:simple_app/models/file_model.dart';
import 'package:simple_app/models/file_manager.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:simple_app/models/settings_manager.dart';
import 'package:highlight/languages/dart.dart';
import 'package:simple_app/widgets/file_tree.dart';
import 'package:simple_app/widgets/side_tab.dart';

// IMPORTANT: Insert your own paiza.io API key here.
// You can get a free key from the paiza.io website.
// Using 'guest' is for demonstration only and may be unreliable.
const String paizaApiKey = 'guest'; // Replace 'guest' with your actual key.

class EditorScreen extends StatefulWidget {
  final FileModel file;

  const EditorScreen({super.key, required this.file});

  @override
  EditorScreenState createState() => EditorScreenState();
}

class SideTabEditor extends StatefulWidget {
  const SideTabEditor({super.key});

  @override
  SideTabEditorState createState() => SideTabEditorState();
}

class SideTabEditorState extends State<SideTabEditor> {
  FileModel? _selectedFile;
  final List<FileModel> _openFiles = [];
  String _consoleOutput = '';

  @override
  void initState() {
    super.initState();
    // Initialize with a default file or get from file manager
    final fileManager = Provider.of<FileManager>(context, listen: false);
    if (fileManager.savedFiles.isNotEmpty) {
      _selectedFile = fileManager.savedFiles.first;
      _openFiles.add(_selectedFile!);
    }
  }

  void _onFileSelected(FileModel file) {
    setState(() {
      _selectedFile = file;
      if (!_openFiles.contains(file)) {
        _openFiles.add(file);
      }
    });
  }

  void _closeFile(FileModel file) {
    setState(() {
      _openFiles.remove(file);
      if (_selectedFile == file) {
        _selectedFile = _openFiles.isNotEmpty ? _openFiles.last : null;
      }
    });
  }

  void _updateConsoleOutput(String output) {
    setState(() {
      _consoleOutput = output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left sidebar - File tree
          SizedBox(
            width: 300,
            child: FileTree(
              onFileSelected: _onFileSelected,
              selectedFile: _selectedFile,
            ),
          ),

          // Main editor area with tabs
          Expanded(
            child: Column(
              children: [
                // Tab bar for open files
                if (_openFiles.isNotEmpty)
                  Container(
                    height: 50,
                    color: Colors.grey[800],
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _openFiles.length,
                      itemBuilder: (context, index) {
                        final file = _openFiles[index];
                        final isSelected = _selectedFile == file;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[900] : Colors.grey[700],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => _onFileSelected(file),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Text(
                                    file.name,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[300],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              if (_openFiles.length > 1)
                                IconButton(
                                  onPressed: () => _closeFile(file),
                                  icon: Icon(Icons.close, size: 16, color: isSelected ? Colors.white : Colors.grey[400]),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                // Editor area
                Expanded(
                  child: _selectedFile != null
                    ? _EditorTabContent(
                        file: _selectedFile!,
                        onConsoleOutput: _updateConsoleOutput,
                      )
                    : const Center(
                        child: Text(
                          'No file selected',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                ),
              ],
            ),
          ),

          // Right sidebar - Console output
          SizedBox(
            width: 400,
            child: Container(
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[700]!, width: 1),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.terminal, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Console',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _consoleOutput.isEmpty ? 'No output yet...' : _consoleOutput,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                          fontSize: 12,
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
}

class _EditorTabContent extends StatefulWidget {
  final FileModel file;
  final Function(String) onConsoleOutput;

  const _EditorTabContent({
    required this.file,
    required this.onConsoleOutput,
  });

  @override
  _EditorTabContentState createState() => _EditorTabContentState();
}

class _EditorTabContentState extends State<_EditorTabContent> {
  late CodeController _codeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.file.content,
      language: dart,
      analyzer: DartPadAnalyzer(),
    );

    _codeController.autocompleter.setCustomWords(const [
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
    ]);

    _codeController.addListener(() {
      widget.file.content = _codeController.text;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);

    return Column(
      children: [
        // Toolbar
        Container(
          height: 50,
          color: Colors.grey[850],
          child: Row(
            children: [
              const SizedBox(width: 16),
              Text(
                widget.file.name,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow, color: Colors.white),
                onPressed: _runCode,
              ),
            ],
          ),
        ),

        // Editor
        Expanded(
          child: CodeTheme(
            data: CodeThemeData(styles: settingsManager.currentTheme),
            child: CodeField(
              controller: _codeController,
              minLines: 10,
              maxLines: null,
              textStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: settingsManager.fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _runCode() async {
    if (_isLoading) return;

    if (paizaApiKey == 'guest' || paizaApiKey.isEmpty) {
      widget.onConsoleOutput('Error: API Key is not set.\nPlease set your paiza.io API key in editor_screen.dart');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String output = '';

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
        output = await _getExecutionDetails(id);
      } else {
        output = 'Error creating runner: ${response.body}';
      }
    } catch (e) {
      output = 'An error occurred: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Provider.of<SettingsManager>(context, listen: false).setLastConsoleOutput(output);
        widget.onConsoleOutput(output);
      }
    }
  }

  Future<String> _getExecutionDetails(String id) async {
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
        return result.isEmpty ? 'Execution finished with no output.' : result;
      } else {
        return 'Error getting details: ${response.body}';
      }
    } catch (e) {
      return 'An error occurred while fetching details: $e';
    }
  }
}

class EditorScreenState extends State<EditorScreen> {
  late CodeController _codeController;
  bool _isLoading = false;
  bool _isSideTabVisible = true;

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

  void _showOutputSheet(String output) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Console Output',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Divider(color: Colors.grey),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    output,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _runCode() async {
    if (_isLoading) return;

    if (paizaApiKey == 'guest' || paizaApiKey.isEmpty) {
      _showOutputSheet('Error: API Key is not set.\nPlease set your paiza.io API key in editor_screen.dart');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String output = ''; // Initialized to fix the null safety error.

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
        output = await _getExecutionDetails(id);
      } else {
        output = 'Error creating runner: ${response.body}';
      }
    } catch (e) {
      output = 'An error occurred: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Save the output and then show it
        Provider.of<SettingsManager>(context, listen: false).setLastConsoleOutput(output);
        _showOutputSheet(output);
      }
    }
  }

  Future<String> _getExecutionDetails(String id) async {
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
        return result.isEmpty ? 'Execution finished with no output.' : result;
      } else {
        return 'Error getting details: ${response.body}';
      }
    } catch (e) {
      return 'An error occurred while fetching details: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);

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
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              setState(() {
                _isSideTabVisible = !_isSideTabVisible;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: CodeTheme(
              data: CodeThemeData(styles: settingsManager.currentTheme),
              child: SingleChildScrollView(
                child: CodeField(
                  controller: _codeController,
                  minLines: 40,
                  textStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: settingsManager.fontSize,
                  ),
                ),
              ),
            ),
          ),
          if (_isSideTabVisible) SideTab(codeController: _codeController),
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