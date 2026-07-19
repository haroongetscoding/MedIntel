import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String _apiKey =
      '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';
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  final List<Map<String, String>> _messages = [
    {
      'role': 'system',
      'content':
          'You are MedIntel Assistant, a helpful and knowledgeable medical AI assistant. '
              'Provide clear, empathetic, and accurate health-related information. '
              'Always remind users to consult a real doctor for serious medical concerns. '
              'Keep responses concise and practical. '
              'Do not give definitive diagnoses or prescribe medications.',
    },
  ];

  Future<String> sendMessage(String userMessage) async {
    _messages.add({'role': 'user', 'content': userMessage});

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': _messages,
              'temperature': 0.7,
              'max_tokens': 1024,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        _messages.add({'role': 'assistant', 'content': reply});
        return reply;
      } else {
        final body = response.body;
        String errorDetail;
        try {
          final errData = jsonDecode(body);
          errorDetail = errData['error']?['message'] ?? response.reasonPhrase ?? 'Unknown error';
        } catch (_) {
          errorDetail = response.reasonPhrase ?? 'Unknown error';
        }
        return 'Error: $errorDetail';
      }
    } catch (e) {
      return 'I apologize, but I encountered a connection issue. Please check your internet and try again.';
    }
  }

  Future<Map<String, dynamic>> calculateWellnessScore(List<Map<String, dynamic>> checkinData) async {
    final prompt = {
      'role': 'user',
      'content':
          'Based on the following daily check-in data for the last 7 days, '
          'analyze the user\'s wellness trend and provide:\n'
          '1. A wellness score from 0-100\n'
          '2. A status label: "Excellent", "Good", "Fair", "Poor", or "Critical"\n'
          '3. A brief 1-sentence analysis\n\n'
          'Check-in data:\n${jsonEncode(checkinData)}\n\n'
          'Respond ONLY with a valid JSON object in this exact format:\n'
          '{"score": 75, "status": "Good", "analysis": "Brief analysis here."}'
    };

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [prompt],
              'temperature': 0.3,
              'max_tokens': 200,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'] as String;
        final parsed = jsonDecode(reply) as Map<String, dynamic>;
        return {
          'score': parsed['score'] ?? 50,
          'status': parsed['status'] ?? 'Fair',
          'analysis': parsed['analysis'] ?? 'Wellness data analyzed.',
        };
      }
    } catch (_) {}

    return {'score': 50, 'status': 'Fair', 'analysis': 'Unable to calculate wellness score.'};
  }

  void resetConversation() {
    _messages.removeWhere((m) => m['role'] != 'system');
  }
}
