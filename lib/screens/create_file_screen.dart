import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/file_manager.dart';
import 'package:simple_app/models/file_model.dart';
import 'package:simple_app/screens/editor_screen.dart';

class CreateFileScreen extends StatefulWidget {
  const CreateFileScreen({super.key});

  @override
  _CreateFileScreenState createState() => _CreateFileScreenState();
}

class _CreateFileScreenState extends State<CreateFileScreen> {
  final _fileNameController = TextEditingController();
  String? _selectedFileType;
  final _fileTypes = ['Dart', 'JSON', 'HTML', 'Text'];

  void _createFile() {
    final fileName = _fileNameController.text;
    final fileType = _selectedFileType;
    final fileManager = Provider.of<FileManager>(context, listen: false);

    if (fileName.isEmpty || fileType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a file name and select a file type.'),
        ),
      );
      return;
    }

    // This check will be improved in a later step
    if (fileManager.fileExists(fileName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A file with the name "$fileName" already exists.'),
        ),
      );
      return;
    }

    final newFile = FileModel(
      name: fileName,
      type: fileType,
      createdDate: DateTime.now(),
    );
    fileManager.addFile(newFile);

    // Navigate to the editor screen with the new file
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditorScreen(file: newFile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New File'),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File Name Input
            Text(
              'File Name',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                hintText: 'e.g., main.dart',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24),

            // File Type Dropdown
            Text(
              'File Type',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFileType,
              hint: const Text('Select a file type'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              items: _fileTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFileType = newValue;
                });
              },
            ),
            const SizedBox(height: 32),

            // Create File Button
            ElevatedButton(
              onPressed: _createFile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Create File',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }
}