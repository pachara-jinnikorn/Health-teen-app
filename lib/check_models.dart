import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // 🔑 PASTE YOUR KEY HERE
  const apiKey = 'AIzaSyD9hnK_cZl10t9ifdJymFvy4tnNun3Xdmc'; 

  print('🔍 Asking Google for available models...');
  
  // We use the 'v1beta' list endpoint
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');

  try {
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('\n✅ SUCCESS! Your Key supports these models:');
      print('---------------------------------------------');
      
      List<dynamic> models = data['models'];
      for (var model in models) {
        // We look for models that support "generateContent"
        if (model['supportedGenerationMethods'].contains('generateContent')) {
          // Print the clean name (e.g. "gemini-1.5-flash")
          print(model['name'].toString().replaceAll('models/', ''));
        }
      }
      print('---------------------------------------------\n');
    } else {
      print('\n❌ API ERROR: ${response.statusCode}');
      print('Message: ${response.body}');
    }
  } catch (e) {
    print('❌ CONNECTION ERROR: $e');
  }
}