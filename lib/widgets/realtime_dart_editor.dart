import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:analyzer/dart/analysis/results.dart';

// A self-contained widget for a real-time Dart code editor with analysis.
class RealTimeDartEditor extends StatefulWidget {
  const RealTimeDartEditor({super.key});

  @override
  State<RealTimeDartEditor> createState() => _RealTimeDartEditorState();
}

class _RealTimeDartEditorState extends State<RealTimeDartEditor> {
  late final CodeController _codeController;

  // Sample Dart code with some issues to demonstrate the analyzer.
  final String _sampleCode = """
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This variable is unused, which should be a warning.
    int unusedVariable = 10;

    // This is a syntax error.
    String text = "Hello, World"

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Real-Time Dart Editor'),
        ),
        body: const Center(
          child: Text(text),
        ),
      ),
    );
  }
}
""";

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: _sampleCode,
      analyzer: DartPadAnalyzer(),
    );

    // Listen to changes in the analysis to rebuild the UI and show issues.
    _codeController.analyzer.analysis.listen((analysis) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The Code Editor field
        Expanded(
          flex: 3,
          child: CodeField(
            controller: _codeController,
            textStyle: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
        // The Analysis Issues panel
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[900],
            child: _buildAnalysisIssuesPanel(),
          ),
        ),
      ],
    );
  }

  // Builds the list of issues found by the analyzer.
  Widget _buildAnalysisIssuesPanel() {
    final analysis = _codeController.analyzer.analysis.value;
    final issues = analysis is ParsedUnitResult
        ? analysis.errors.map((e) => e.message).toList()
        : ['Analysis running...'];

    if (issues.isEmpty) {
      return const Center(
        child: Text(
          'No issues found.',
          style: TextStyle(color: Colors.green),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: issues.length,
      itemBuilder: (context, index) {
        final issue = issues[index];
        // Note: Getting the exact line number from the ParsedUnitResult
        // requires more complex handling, so we are displaying the message directly.
        return Text(
          issue,
          style: const TextStyle(color: Colors.redAccent, fontFamily: 'monospace'),
        );
      },
    );
  }
}
