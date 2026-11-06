class ChapterDirectoryItem {
  final String id;
  final String name;
  final String location;
  final String districtName;
  final int memberCount;
  final String? image;
  final DateTime? createdAt;

  const ChapterDirectoryItem({
    required this.id,
    required this.name,
    required this.location,
    required this.districtName,
    required this.memberCount,
    this.image,
    this.createdAt,
  });
}
