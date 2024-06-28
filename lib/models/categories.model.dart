class Categories {
  final String id;
  final String categoryName;
  final String? img;
  final int? courseCount;

  Categories({
    required this.id,
    required this.categoryName,
    required this.img,
    this.courseCount,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: json['_id'],
      categoryName: json['category_name'],
      img: json['img'],
      courseCount: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category_name': categoryName,
      'img': img,
      'count': courseCount,
    };
  }
}
