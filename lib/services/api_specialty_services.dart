import 'dart:convert';
import 'package:course_app/configs/configs.dart';
import 'package:course_app/models/specialty.model.dart';
import 'package:http/http.dart' as http;

class ApiSpecialtyServices {
  static Future<List<Specialty>> fetchSpecialties() async {
    final url = Uri.parse(specialty);
    final response = await http.get(url);
    print('fetch specialty: $specialty');
    if (response.statusCode == 200) {
      final List<dynamic> specialtiesJson = jsonDecode(response.body);
      return specialtiesJson.map((json) => Specialty.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load specialties');
    }
  }

  static Future<Specialty> fetchSpecialtyById(String id) async {
    final url = Uri.parse('$specialty$id');
    final response = await http.get(url);
    print('fetch specialty by id: $url');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final specialtyJson = responseBody['specialty'];
      return Specialty.fromJson(specialtyJson);
    } else {
      throw Exception('Failed to load specialty by id');
    }
  }
}
