import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/file_manager.dart';
import 'package:intl/intl.dart';
import 'package:simple_app/screens/editor_screen.dart';

class FileListView extends StatelessWidget {
  const FileListView({super.key});

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
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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