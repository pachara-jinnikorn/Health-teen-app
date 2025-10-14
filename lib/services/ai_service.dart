import '../models/health_data.dart';

class AIService {
  /// Send a message to the AI chatbot and get a response
  Future<String> sendMessage({
    required String conversationId,
    required String message,
    HealthData? userHealthData,
  }) async {
    try {
      // Simulate AI processing delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate response based on message content
      String response = _generateAIResponse(message, userHealthData);

      return response;
    } catch (e) {
      print('Error calling AI service: $e');
      return "I'm having trouble responding right now. Please try again in a moment.";
    }
  }

  /// Generate AI response based on user message and health data
  String _generateAIResponse(String message, HealthData? healthData) {
    final msg = message.toLowerCase();

    // Sleep-related queries
    if (msg.contains('sleep') || msg.contains('tired') || msg.contains('rest')) {
      if (healthData != null && healthData.sleep < 7) {
        return "I notice you're getting ${healthData.sleep} hours of sleep. The recommended amount for teens is 8-10 hours. Try setting a consistent bedtime routine to improve your sleep quality!";
      }
      return "Good sleep is crucial for your health! Aim for 8-10 hours per night. Try avoiding screens an hour before bed and keeping your room cool and dark.";
    }

    // Steps/exercise queries
    if (msg.contains('step') || msg.contains('walk') || msg.contains('exercise') || msg.contains('workout')) {
      if (healthData != null && healthData.steps < 8000) {
        return "You've walked ${healthData.steps} steps today. Great start! The goal is 10,000 steps daily. Try taking short walking breaks throughout the day to reach your goal!";
      } else if (healthData != null && healthData.steps >= 10000) {
        return "Amazing! You've already hit ${healthData.steps} steps today! 🎉 Keep up the fantastic work. Regular physical activity is one of the best things you can do for your health.";
      }
      return "Regular exercise is essential! Aim for at least 60 minutes of physical activity daily. This can include walking, sports, dancing, or any activity you enjoy!";
    }

    // Nutrition/calories queries
    if (msg.contains('food') || msg.contains('eat') || msg.contains('calorie') || msg.contains('nutrition')) {
      return "Nutrition is key to feeling your best! Focus on whole foods like fruits, vegetables, lean proteins, and whole grains. Stay hydrated and try to limit processed foods and sugary drinks.";
    }

    // Motivation/encouragement
    if (msg.contains('motivat') || msg.contains('help') || msg.contains('start')) {
      return "You're taking great steps toward better health! Remember, small consistent changes lead to big results. I'm here to support you every step of the way. What specific goal would you like to work on?";
    }

    // Mental health
    if (msg.contains('stress') || msg.contains('anxious') || msg.contains('mental')) {
      return "Your mental health is just as important as physical health. Try practicing mindfulness, deep breathing exercises, or talking to someone you trust. Regular exercise and good sleep also help manage stress!";
    }

    // General health advice
    if (msg.contains('healthy') || msg.contains('health') || msg.contains('advice')) {
      String advice = "Here are some key health tips for teens:\n\n";
      advice += "🌙 Sleep: 8-10 hours per night\n";
      advice += "💪 Exercise: 60 minutes daily\n";
      advice += "🥗 Nutrition: Balanced meals with fruits & veggies\n";
      advice += "💧 Hydration: 8 glasses of water daily\n";
      advice += "🧘 Mental Health: Take breaks and practice self-care\n\n";
      advice += "What area would you like to focus on?";
      return advice;
    }

    // Greetings
    if (msg.contains('hi') || msg.contains('hello') || msg.contains('hey')) {
      return "Hello! I'm Dr. Wellness, your AI health coach. I can help with sleep, nutrition, exercise, and general wellness advice. What would you like to know about?";
    }

    // Default response with context from health data
    if (healthData != null) {
      return "Thanks for reaching out! I see you're at ${healthData.steps} steps, ${healthData.sleep}h sleep, and ${healthData.calories} calories today. How can I help you with your health goals?";
    }

    return "Hi! I'm Dr. Wellness, your AI health coach. I can help with sleep, nutrition, exercise, and general wellness advice. What would you like to know about?";
  }

  /// Check if user has reached message limit (for free tier)
  Future<bool> canSendMessage(String userId, bool isPremium) async {
    if (isPremium) return true;
    return true;
  }

  /// Get AI-generated health insights based on user data
  Future<String> getHealthInsights(HealthData healthData) async {
    try {
      String insights = "🎯 Your Health Insights:\n\n";

      // Sleep insights
      if (healthData.sleep >= 8) {
        insights += "✅ Great sleep habits! You're getting ${healthData.sleep}h of rest.\n";
      } else if (healthData.sleep >= 7) {
        insights += "😴 You're getting ${healthData.sleep}h of sleep. Try to increase to 8-10 hours.\n";
      } else {
        insights += "⚠️ Sleep needs improvement. You're only getting ${healthData.sleep}h. Aim for 8-10 hours.\n";
      }

      // Steps insights
      if (healthData.steps >= 10000) {
        insights += "✅ Excellent! You've hit your daily step goal of ${healthData.steps} steps!\n";
      } else if (healthData.steps >= 7000) {
        insights += "📈 Good progress! You're at ${healthData.steps} steps. Push for 10,000!\n";
      } else {
        insights += "💪 Let's move more! You're at ${healthData.steps} steps. Goal is 10,000.\n";
      }

      // Calories insights
      insights += "\n🔥 Calories burned: ${healthData.calories}\n";
      insights += "\nKeep up the great work! Consistency is key to reaching your health goals.";

      return insights;
    } catch (e) {
      print('Error getting health insights: $e');
      return "Keep up the great work! Stay consistent with your health goals.";
    }
  }
}