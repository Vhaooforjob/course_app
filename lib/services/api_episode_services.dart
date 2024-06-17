import 'package:course_app/models/episodes.model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../configs/configs.dart';

Future<Episode> fetchEpisodeById(String episodeId) async {
  final response = await http.get(Uri.parse('${episode}$episodeId'));
  print('fetch episode: ${episode}$episodeId');
  if (response.statusCode == 200) {
    return Episode.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load episode');
  }
}
