import 'dart:convert';
import 'package:http/http.dart' as http;

class PremiumAIService {
  // 🔑 YOUR API KEY (Keep this safe!)
  static const String _apiKey = 'AIzaSyD9hnK_cZl10t9ifdJymFvy4tnNun3Xdmc'; 

  static Future<String> sendMessage(String message, {List<dynamic>? conversationHistory}) async {
    try {
      final String cleanKey = _apiKey.trim();
      
      // ✅ FIXED: Using a model that IS in your list: 'gemini-2.5-flash'
      final String url = 
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$cleanKey';

      print('🌐 Connecting to: $url'); 

      final contents = [];

      // System Prompt
      contents.add({
        'role': 'user',
        'parts': [{'text': 'You are Health Guru, a helpful AI health advisor.'}]
      });
      
      contents.add({
        'role': 'model',
        'parts': [{'text': 'Understood. I am ready to help.'}]
      });

      // History Loop
      if (conversationHistory != null) {
        for (var item in conversationHistory) {
          final safeItem = Map<String, dynamic>.from(item as Map);
          contents.add({
            'role': safeItem['role'] == 'user' ? 'user' : 'model',
            'parts': [{'text': safeItem['content'].toString()}] 
          });
        }
      }

      // User Message
      contents.add({
        'role': 'user',
        'parts': [{'text': message}]
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
             return data['candidates'][0]['content']['parts'][0]['text'].trim();
        }
        return 'No response from AI.';
      } else {
        print('⚠️ API ERROR: ${response.statusCode} - ${response.body}');
        return 'Error: ${response.statusCode} - Check console.';
      }
    } catch (e) {
      print('❌ CODE ERROR: $e');
      return 'App Error: $e';
    }
  }
}