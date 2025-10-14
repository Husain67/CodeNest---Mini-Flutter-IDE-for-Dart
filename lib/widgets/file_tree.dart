import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_app/models/file_manager.dart';
import 'package:simple_app/models/file_model.dart';
import 'package:simple_app/screens/editor_screen.dart';
import 'package:intl/intl.dart';

class FileTree extends StatefulWidget {
  final Function(FileModel) onFileSelected;
  final FileModel? selectedFile;

  const FileTree({
    super.key,
    required this.onFileSelected,
    this.selectedFile,
  });

  @override
  FileTreeState createState() => FileTreeState();
}

class FileTreeState extends State<FileTree> {
  final Map<String, bool> _expandedNodes = {};

  @override
  Widget build(BuildContext context) {
    return Consumer<FileManager>(
      builder: (context, fileManager, child) {
        return Container(
          color: Colors.grey[900],
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
                    Icon(Icons.folder, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Files',
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
                child: ListView.builder(
                  itemCount: fileManager.savedFiles.length,
                  itemBuilder: (context, index) {
                    final file = fileManager.savedFiles[index];
                    final isSelected = widget.selectedFile?.name == file.name &&
                                     widget.selectedFile?.createdDate == file.createdDate;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      color: isSelected ? Colors.blue[900] : Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          Icons.insert_drive_file,
                          color: isSelected ? Colors.white : Colors.grey[400],
                          size: 18,
                        ),
                        title: Text(
                          file.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd().format(file.createdDate),
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () => widget.onFileSelected(file),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}