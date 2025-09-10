import 'dart:typed_data';

class Blog {
  final String id;
  final String title;
  final String content;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String imageUrl;
  final String? name;
  final Uint8List? image;
  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
    this.name,
    this.image,
  });
}
