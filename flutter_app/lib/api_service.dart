
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Kareem will provide the HTTPS server URL.
  static const String baseUrl = '';

  // Check whether the backend is reachable.
  static Future<bool> checkConnection() async {
    if (baseUrl.isEmpty) return false;

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Upload an audio file for deepfake detection.
  static Future<Map<String, dynamic>> analyzeDeepfake(
    String filePath,
  ) async {
    return uploadAudio('/api/deepfake', filePath);
  }

  // Upload an audio file for sound recognition.
  static Future<Map<String, dynamic>> recognizeSound(
    String filePath,
  ) async {
    return uploadAudio('/api/sound', filePath);
  }

  // Send the file using multipart/form-data.
  static Future<Map<String, dynamic>> uploadAudio(
    String endpoint,
    String filePath,
  ) async {
    if (baseUrl.isEmpty) {
      throw Exception('Backend URL is not configured yet.');
    }

    final uri = Uri.parse('$baseUrl$endpoint');

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Server error: ${response.statusCode} - ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected server response.');
    }

    return decoded;
  }
}
