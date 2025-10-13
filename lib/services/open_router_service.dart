import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<String> getChatCompletion({
    required String apiKey,
    required String modelName,
    required String userMessage,
  }) async {
    if (apiKey.isEmpty) {
      return 'Error: API Key is not set. Please set it in the settings.';
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': modelName,
          'messages': [
            {'role': 'user', 'content': userMessage},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'].toString();
        }
        return 'Error: Received an empty response from the API.';
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown API Error';
        return 'Error ${response.statusCode}: $errorMessage';
      }
    } catch (e) {
      return 'Error: Failed to connect to the server. Please check your internet connection. Details: $e';
    }
  }
}
