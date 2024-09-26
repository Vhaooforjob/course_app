import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> uploadImage(File imageFile) async {
  const String uploadPreset = 'ml_default';
  const String couldName = 'dpqaahisi';
  const String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/$couldName/image/upload';
  try {
    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
    request.fields['upload_preset'] = uploadPreset;

    final file = await http.MultipartFile.fromPath('file', imageFile.path);
    request.files.add(file);

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(responseData.body);
      return responseJson['secure_url'];
    } else {
      print('Error: ${responseData.body}');
      return null;
    }
  } catch (e) {
    print('Exception: $e');
    return null;
  }
}
