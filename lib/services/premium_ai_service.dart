import 'dart:convert';
import 'package:http/http.dart' as http;

class PremiumAIService {
  // 🔑 REPLACE THIS WITH YOUR ACTUAL API KEY FROM STEP 1
  static const String _apiKey = 'AIzaSyD9hnK_cZl10t9ifdJymFvy4tnNun3Xdmc';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  static Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      final systemPrompt = '''You are an advanced AI health advisor for teenagers named "Health Guru". 
Your role is to:
- Provide personalized health, fitness, nutrition, and wellness advice
- Remember previous conversation context
- Give detailed, actionable recommendations
- Be empathetic, encouraging, and non-judgmental
- Use emojis naturally in conversation
- Remind users to consult healthcare professionals for serious concerns
- Keep responses informative but conversational (2-4 paragraphs)

You have access to the user's conversation history and should reference it when relevant.''';

      final contents = <Map<String, dynamic>>[];
      
      contents.add({
        'role': 'user',
        'parts': [{'text': systemPrompt}]
      });
      
      contents.add({
        'role': 'model',
        'parts': [{'text': 'Hello! I\'m Health Guru, your advanced AI health advisor. I remember our conversations and provide personalized guidance. How can I help you today? 😊'}]
      });

      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (var msg in conversationHistory) {
          contents.add({
            'role': msg['role'] == 'user' ? 'user' : 'model',
            'parts': [{'text': msg['content'] ?? ''}]
          });
        }
      }

      contents.add({
        'role': 'user',
        'parts': [{'text': message}]
      });

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 600,
            'topP': 0.8,
            'topK': 40,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text.trim();
        }
      }
      
      return 'I apologize, but I\'m having trouble right now. Please try again.';
    } catch (e) {
      print('❌ Premium AI Error: $e');
      return 'Sorry, I\'m having trouble connecting. Please check your internet connection.';
    }
  }
}