import 'package:cloud_functions/cloud_functions.dart';
import '../models/health_data.dart';

class AIService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Send a message to the AI chatbot and get a response
  Future<String> sendMessage({
    required String conversationId,
    required String message,
    HealthData? userHealthData,
  }) async {
    try {
      // Call Cloud Function
      final callable = _functions.httpsCallable('sendAIMessage');
      
      final result = await callable.call({
        'conversationId': conversationId,
        'message': message,
        'userHealthData': userHealthData != null ? {
          'steps': userHealthData.steps,
          'sleep': userHealthData.sleep,
          'calories': userHealthData.calories,
        } : null,
      });

      if (result.data['success'] == true) {
        return result.data['response'] as String;
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      print('Error calling AI service: $e');
      // Return a fallback response
      return "I'm having trouble connecting right now. Please try again in a moment.";
    }
  }

  /// Check if user has reached message limit (for free tier)
  Future<bool> canSendMessage(String userId, bool isPremium) async {
    if (isPremium) return true;

    // For free users, check message count this month
    // This would query Firestore to count messages
    // For now, return true (implement later)
    return true;
  }

  /// Get AI-generated health insights based on user data
  Future<String> getHealthInsights(HealthData healthData) async {
    try {
      final callable = _functions.httpsCallable('getHealthInsights');
      
      final result = await callable.call({
        'healthData': {
          'steps': healthData.steps,
          'sleep': healthData.sleep,
          'calories': healthData.calories,
          'weeklyData': healthData.weeklySteps,
        },
      });

      return result.data['insights'] as String;
    } catch (e) {
      print('Error getting health insights: $e');
      return "Keep up the great work! Stay consistent with your health goals.";
    }
  }
}
