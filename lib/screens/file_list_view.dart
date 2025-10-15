import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/file_manager.dart';
import 'package:intl/intl.dart';
import 'package:simple_app/models/file_model.dart';
import 'package:simple_app/screens/editor_screen.dart';

class FileListView extends StatelessWidget {
  const FileListView({super.key});

  Future<void> _showRenameDialog(BuildContext context, FileManager fileManager, FileModel file) async {
    final TextEditingController renameController = TextEditingController(text: file.name);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: renameController,
            decoration: const InputDecoration(hintText: "Enter new file name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () {
                final newName = renameController.text;
                if (newName.isNotEmpty && !fileManager.fileExists(newName)) {
                  fileManager.renameFile(file, newName);
                  Navigator.of(context).pop();
                } else {
                  // Optional: Show an error snackbar or message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newName.isEmpty
                            ? 'File name cannot be empty.'
                            : 'A file with this name already exists.',
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Files'),
        backgroundColor: Colors.grey[850],
      ),
      body: Consumer<FileManager>(
        builder: (context, fileManager, child) {
          return ListView.builder(
            itemCount: fileManager.savedFiles.length,
            itemBuilder: (context, index) {
              final file = fileManager.savedFiles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: Colors.grey[800],
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file, color: Colors.white),
                  title: Text(file.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    DateFormat.yMMMd().format(file.createdDate),
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        fileManager.deleteFile(file);
                      } else if (value == 'rename') {
                        _showRenameDialog(context, fileManager, file);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'rename',
                        child: Text('Rename'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditorScreen(file: file),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}