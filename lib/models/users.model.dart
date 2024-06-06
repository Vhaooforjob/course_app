class User {
  final String username;
  final String email;
  final String fullName;

  User({required this.username, required this.email, required this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
    );
  }
}
