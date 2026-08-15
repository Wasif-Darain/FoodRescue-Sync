import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ListingImageManager {
  static const String cloudName = 'lobecgxv';
  static const String uploadPreset = 'foodrescue_preset';

  Future<String> uploadListingImage(File file) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }
}