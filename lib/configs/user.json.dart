class UserJson {
  final String id;
  final String username;
  final String password;
  final String email;
  final String fullName;
  final DateTime joinDate;
  final String? imageUrl;
  final String? specialty;

  UserJson({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
    required this.joinDate,
    this.imageUrl,
    this.specialty,
  });

  factory UserJson.fromJson(Map<String, dynamic> json) {
    return UserJson(
      id: json['_id'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      fullName: json['full_name'],
      joinDate: DateTime.parse(json['join_date']),
      imageUrl: json['image_url'],
      specialty: json['specialty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'password': password,
      'email': email,
      'full_name': fullName,
      'join_date': joinDate.toIso8601String(),
      'image_url': imageUrl,
      'specialty': specialty,
    };
  }
}
