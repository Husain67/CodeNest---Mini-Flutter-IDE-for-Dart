class FileModel {
  final String name;
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