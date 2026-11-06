class LevelRoleUpload {
  final String id;
  final String type;
  final String title;
  final String description;
  final String fileUrl;
  final String fileName;
  final String mimeType;
  final String role;
  final String levelName;
  final DateTime? createdAt;

  LevelRoleUpload({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.fileName,
    required this.mimeType,
    required this.role,
    required this.levelName,
    required this.createdAt,
  });

  factory LevelRoleUpload.fromJson(Map<String, dynamic> json) {
    return LevelRoleUpload(
      id: (json['_id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      fileUrl: (json['fileUrl'] ?? '').toString(),
      fileName: (json['fileName'] ?? '').toString(),
      mimeType: (json['mimeType'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      levelName: (json['levelName'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }

  bool get isMar =>
      type.toLowerCase() == 'report' &&
      title.toLowerCase().startsWith('mar');
}
