import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  CloudinaryService._();

  static String get cloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'pej3fl8t';
  static String get apiKey =>
      dotenv.env['CLOUDINARY_API_KEY'] ?? '562957333999676';
  static String get apiSecret =>
      dotenv.env['CLOUDINARY_API_SECRET'] ?? 'yM0wvt_nibk6RxkO_wdE4SkT8P8';
  static String get uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'preply_preset';

  /// Uploads an image to Cloudinary and returns the secure URL.
  static Future<String> uploadImage(XFile imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final bytes = await imageFile.readAsBytes();
    final filename = imageFile.name.isNotEmpty ? imageFile.name : 'avatar.jpg';

    // 1. Try unsigned upload with upload_preset (most common for client-side uploads)
    try {
      final unsignedRequest = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: filename),
        );

      final streamedResponse = await unsignedRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final url = data['secure_url'] ?? data['url'];
        if (url != null) return url.toString();
      }
    } catch (_) {}

    // 2. Try signed upload with upload_preset + signature
    final timestamp =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    try {
      final toSign =
          'timestamp=$timestamp&upload_preset=$uploadPreset$apiSecret';
      final signature = sha1.convert(utf8.encode(toSign)).toString();

      final signedPresetReq = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['api_key'] = apiKey
        ..fields['timestamp'] = timestamp
        ..fields['signature'] = signature
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: filename),
        );

      final streamedResponse = await signedPresetReq.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final url = data['secure_url'] ?? data['url'];
        if (url != null) return url.toString();
      }
    } catch (_) {}

    // 3. Try standard signed upload without preset (api_key + timestamp + signature)
    final toSignNoPreset = 'timestamp=$timestamp$apiSecret';
    final signatureNoPreset =
        sha1.convert(utf8.encode(toSignNoPreset)).toString();

    final signedReq = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp
      ..fields['signature'] = signatureNoPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

    final streamedResponse = await signedReq.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final url = data['secure_url'] ?? data['url'];
      if (url != null) return url.toString();
    }

    try {
      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['error']?['message'] ??
            'Failed to upload image to Cloudinary (${response.statusCode})',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to upload image to Cloudinary: ${response.body}');
    }
  }
}
