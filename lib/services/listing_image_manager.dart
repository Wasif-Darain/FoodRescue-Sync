import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ListingImageManager {
  static const String cloudName = 'lobecgxv';
  static const String uploadPreset = 'foodrescue_preset';

  Future<String> uploadListingImage(File file) async {
    return uploadBytes(await file.readAsBytes());
  }

  /// Uploads raw image bytes directly, without a filesystem round-trip —
  /// safer than [uploadListingImage] on iOS, where writing to the app's temp
  /// directory right after a UIImagePickerController camera capture can
  /// intermittently fail (the file the multipart request tries to read back
  /// from disk is missing), surfacing as a generic upload failure.
  Future<String> uploadBytes(Uint8List bytes, {String filename = 'upload.jpg'}) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final response = await request.send().timeout(const Duration(seconds: 30));
    final responseBody = await response.stream.bytesToString();
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null) {
      throw Exception('Cloudinary upload failed: ${json['error']?['message'] ?? responseBody}');
    }
    return url;
  }
}