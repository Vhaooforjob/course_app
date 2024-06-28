import 'package:http/http.dart' as http;
import 'dart:convert';
import '../configs/configs.dart';
import 'package:course_app/models/categories.model.dart';

class ApiCategoryServices {
  static Future<List<Categories>> fetchCategories() async {
    final response = await http.get(Uri.parse(categories));
    print('fetch categories with: $categories');
    if (response.statusCode == 200) {
      List<Categories> categories = [];
      List<dynamic> jsonResponse = json.decode(response.body);

      for (var item in jsonResponse) {
        categories.add(Categories.fromJson(item));
      }

      return categories;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<Categories> fetchCategoryById(String categoryId) async {
    final response =
        await http.get(Uri.parse('${courses}category/$categoryId'));
    print('fetch category with: ${courses}category/$categoryId');
    if (response.statusCode == 200) {
      return Categories.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load category');
    }
  }

  static Future<Categories> createCategory(Categories category) async {
    final response = await http.post(
      Uri.parse(categories),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode == 201) {
      return Categories.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create category');
    }
  }

  static Future<Categories> updateCategory(
      String categoryId, Categories category) async {
    final response = await http.put(
      Uri.parse('$categories/$categoryId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode == 200) {
      return Categories.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update category');
    }
  }

  static Future<void> deleteCategory(String categoryId) async {
    final response = await http.delete(Uri.parse('$categories/$categoryId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }
}
