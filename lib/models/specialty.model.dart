class Specialty {
  final String id;
  final String specialtyName;

  Specialty({required this.id, required this.specialtyName});

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: json['_id'],
      specialtyName: json['specialty_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'specialty_name': specialtyName,
    };
  }
}
