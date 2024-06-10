class Course {
  final String id;
  final String title;
  final String description;
  final String imageUrl;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}
