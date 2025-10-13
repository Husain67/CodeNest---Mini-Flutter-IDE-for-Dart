class FileModel {
  String name; // Removed 'final' to allow renaming
  final String type;
  final DateTime createdDate;
  String content;

  FileModel({
    required this.name,
    required this.type,
    required this.createdDate,
    this.content = '',
  });
}