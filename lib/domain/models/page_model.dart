class PageModel {
  final int id;
  final int position;
  final int folderId;
  final String imagePath;
  final String recognizedText;
  final String text;
  final DateTime createdAt;

  PageModel({
    required this.id,
    required this.position,
    required this.folderId,
    required this.imagePath,
    required this.recognizedText,
    required this.text,
    required this.createdAt,
  });
}
