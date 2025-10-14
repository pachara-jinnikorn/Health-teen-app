# AI Chatbot Implementation Guide

## Overview
This guide shows you how to add a working AI chatbot (Dr. Wellness) to your Health Teen app using Firebase Cloud Functions and OpenAI API.

## Architecture

\`\`\`
Flutter App (Frontend)
    ↓
Firebase Cloud Functions (Backend)
    ↓
OpenAI API (AI Service)
\`\`\`

## Step 1: Set Up Firebase Project

### 1.1 Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Name it "health-teen"
4. Follow the setup wizard

### 1.2 Enable Firestore Database
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select your region

### 1.3 Add Firebase to Flutter App
\`\`\`bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase in your Flutter project
cd health_teen
flutterfire configure
\`\`\`

## Step 2: Set Up Cloud Functions

### 2.1 Initialize Cloud Functions
\`\`\`bash
# In your project root
firebase init functions

# Choose:
# - JavaScript or TypeScript (choose JavaScript for simplicity)
# - Install dependencies: Yes
\`\`\`

### 2.2 Install Required Packages
\`\`\`bash
cd functions
npm install openai
npm install firebase-admin
npm install firebase-functions
\`\`\`

### 2.3 Get OpenAI API Key
1. Go to https://platform.openai.com
2. Sign up or log in
3. Go to API Keys section
4. Create new secret key
5. Copy the key (you'll need it)

### 2.4 Set Environment Variable
\`\`\`bash
firebase functions:config:set openai.key="YOUR_OPENAI_API_KEY_HERE"
\`\`\`

## Step 3: Create Cloud Function

Create `functions/index.js`:

\`\`\`javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { OpenAI } = require('openai');

admin.initializeApp();

const openai = new OpenAI({
  apiKey: functions.config().openai.key,
});

exports.sendAIMessage = functions.https.onCall(async (data, context) => {
  try {
    // Get user ID from auth context
    const userId = context.auth?.uid;
    if (!userId) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { conversationId, message, userHealthData } = data;

    // Get conversation history from Firestore
    const messagesRef = admin.firestore()
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .orderBy('timestamp', 'desc')
      .limit(10);
    
    const snapshot = await messagesRef.get();
    const history = snapshot.docs.map(doc => doc.data()).reverse();

    // Build context with health data
    const systemPrompt = `You are Dr. Wellness, a friendly AI health coach for the Health Teen app. 
    
User's current health data:
- Steps today: ${userHealthData?.steps || 0}
- Sleep last night: ${userHealthData?.sleep || 0} hours
- Calories burned: ${userHealthData?.calories || 0}

Provide supportive, encouraging advice. Keep responses concise (2-3 sentences). 
Focus on healthy habits, motivation, and practical tips.`;

    // Build messages array for OpenAI
    const messages = [
      { role: 'system', content: systemPrompt },
      ...history.map(msg => ({
        role: msg.isMe ? 'user' : 'assistant',
        content: msg.content
      })),
      { role: 'user', content: message }
    ];

    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: messages,
      max_tokens: 150,
      temperature: 0.7,
    });

    const aiResponse = completion.choices[0].message.content;

    // Save both messages to Firestore
    const batch = admin.firestore().batch();
    
    // User message
    const userMessageRef = admin.firestore()
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .doc();
    
    batch.set(userMessageRef, {
      id: userMessageRef.id,
      sender: 'You',
      content: message,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isMe: true,
      userId: userId,
    });

    // AI response
    const aiMessageRef = admin.firestore()
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .doc();
    
    batch.set(aiMessageRef, {
      id: aiMessageRef.id,
      sender: 'Dr. Wellness',
      content: aiResponse,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isMe: false,
    });

    // Update conversation metadata
    const conversationRef = admin.firestore()
      .collection('conversations')
      .doc(conversationId);
    
    batch.update(conversationRef, {
      lastMessage: aiResponse,
      lastMessageTime: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();

    return {
      success: true,
      response: aiResponse,
      messageId: aiMessageRef.id,
    };

  } catch (error) {
    console.error('Error in sendAIMessage:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
\`\`\`

### 2.5 Deploy Cloud Function
\`\`\`bash
firebase deploy --only functions
\`\`\`

## Step 4: Update Flutter App

### 4.1 Add Firebase Dependencies
Already in your `pubspec.yaml`, but verify:
\`\`\`yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  cloud_functions: ^4.6.0
\`\`\`

### 4.2 Create AI Service

See `lib/services/ai_service.dart` (created below)

### 4.3 Update Chat Provider

See updated `lib/providers/chat_provider.dart` (created below)

## Step 5: Test the Chatbot

1. Run your Flutter app
2. Navigate to Chat screen
3. Open "Dr. Wellness" conversation
4. Send a message like "I'm feeling tired today"
5. Wait 2-3 seconds for AI response

## Cost Estimation

OpenAI GPT-3.5-turbo pricing (as of 2024):
- Input: $0.0015 per 1K tokens
- Output: $0.002 per 1K tokens

Average conversation:
- ~100 tokens per message = $0.0002
- 1000 messages = $0.20

Very affordable for development and small-scale use!

## Security Best Practices

### Firestore Security Rules
\`\`\`javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own conversations
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.userId;
      
      match /messages/{messageId} {
        allow read: if request.auth != null 
          && request.auth.uid == get(/databases/$(database)/documents/conversations/$(conversationId)).data.userId;
        allow write: if request.auth != null;
      }
    }
  }
}
\`\`\`

## Troubleshooting

### "Function not found"
- Make sure you deployed: `firebase deploy --only functions`
- Check Firebase Console > Functions to see if it's deployed

### "OpenAI API error"
- Verify API key is set: `firebase functions:config:get`
- Check OpenAI account has credits

### "Permission denied"
- Make sure user is authenticated
- Check Firestore security rules

### "Timeout"
- OpenAI can take 2-5 seconds to respond
- Increase timeout in Flutter: `timeout: Duration(seconds: 30)`

## Next Steps

1. Add typing indicator while AI is responding
2. Implement message rate limiting (prevent spam)
3. Add conversation history persistence
4. Implement premium features (unlimited messages)
5. Add health data analysis and insights
6. Implement push notifications for AI responses

## Alternative AI Services

If you don't want to use OpenAI:

- **Google Gemini**: Free tier available, good for health advice
- **Anthropic Claude**: Better at nuanced conversations
- **Cohere**: Good free tier for startups
- **Hugging Face**: Open-source models, self-hosted

Just replace the OpenAI API calls with your chosen service's API.
