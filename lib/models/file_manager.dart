import 'package:flutter/material.dart';
import 'package:simple_app/models/file_model.dart';

class FileManager extends ChangeNotifier {
  static final FileManager _instance = FileManager._internal();

  factory FileManager() {
    return _instance;
  }

  FileManager._internal();

  final List<FileModel> _savedFiles = [
    FileModel(
      name: 'main.dart',
      type: 'Dart',
      createdDate: DateTime(2023, 10, 26),
      content: 'void main() {\n  print("Hello, Dart!");\n}',
    ),
    FileModel(
      name: 'index.html',
      type: 'HTML',
      createdDate: DateTime(2023, 10, 25),
      content: '<h1>Hello, HTML!</h1>',
    ),
    FileModel(
      name: 'data.json',
      type: 'JSON',
      createdDate: DateTime(2023, 10, 24),
      content: '{\n  "message": "Hello, JSON!"\n}',
    ),
  ];

  List<FileModel> get savedFiles => _savedFiles;

  void addFile(FileModel file) {
    _savedFiles.add(file);
    notifyListeners();
  }

  void deleteFile(FileModel file) {
    _savedFiles.remove(file);
    notifyListeners();
  }

  bool fileExists(String name) {
    return _savedFiles.any((file) => file.name == name);
  }
}