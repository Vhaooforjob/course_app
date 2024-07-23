import 'dart:convert';
import 'package:course_app/configs/configs.dart';
import 'package:course_app/models/comment.model.dart';
import 'package:http/http.dart' as http;

class ApiCommentServices {
  Future<List<Comment>> getComments() async {
    final response = await http.get(Uri.parse('$comments/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Comment> getCommentById(String id) async {
    final response = await http.get(Uri.parse('$comments/$id'));

    if (response.statusCode == 200) {
      return Comment.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Comment not found');
    } else {
      throw Exception('Failed to load comment');
    }
  }

  Future<List<Comment>> getCommentsByUserId(String userId) async {
    final response = await http.get(Uri.parse('${comments}user/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('No comments found for this user');
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<List<Comment>> getCommentsByEpisodeId(String episodeId) async {
    final response = await http.get(Uri.parse('${comments}episode/$episodeId'));
    print('fetch comment episode: ${comments}episode/$episodeId');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((comment) => Comment.fromJson(comment)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('No comments found for this episode');
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Comment> createComment(Comment comment) async {
    final response = await http.post(
      Uri.parse(comments),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(comment.toJson()),
    );

    if (response.statusCode == 201) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create comment');
    }
  }

  Future<Comment> updateComment(String id, Comment comment) async {
    final response = await http.put(
      Uri.parse('$comments$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(comment.toJson()),
    );

    if (response.statusCode == 200) {
      return Comment.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Comment not found');
    } else {
      throw Exception('Failed to update comment');
    }
  }

  Future<void> deleteComment(String id) async {
    final response = await http.delete(Uri.parse('$comments$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }
}
