# Quick Start: AI Chatbot

This guide gets your AI chatbot working in 15 minutes.

## Prerequisites

- Flutter installed and working
- Firebase account (free tier is fine)
- OpenAI account (free $5 credit for new users)

## Step 1: Firebase Setup (5 minutes)

### Create Firebase Project
\`\`\`bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# In your Flutter project directory
cd health_teen
flutterfire configure
\`\`\`

Select your Firebase project or create a new one.

### Enable Firestore
1. Go to Firebase Console: https://console.firebase.google.com
2. Select your project
3. Click "Firestore Database" → "Create database"
4. Choose "Start in test mode"
5. Select your region

## Step 2: OpenAI Setup (2 minutes)

### Get API Key
1. Go to https://platform.openai.com
2. Sign up (get $5 free credit)
3. Go to API Keys section
4. Click "Create new secret key"
5. Copy the key (starts with `sk-...`)

## Step 3: Deploy Cloud Function (5 minutes)

### Initialize Functions
\`\`\`bash
# In your project root
firebase init functions

# Choose:
# - JavaScript
# - Yes to install dependencies
\`\`\`

### Install Packages
\`\`\`bash
cd functions
npm install openai firebase-admin firebase-functions
\`\`\`

### Set API Key
\`\`\`bash
firebase functions:config:set openai.key="YOUR_API_KEY_HERE"
\`\`\`

### Copy Function Code
Copy the code from `AI_CHATBOT_GUIDE.md` section "Step 3: Create Cloud Function" into `functions/index.js`

### Deploy
\`\`\`bash
firebase deploy --only functions
\`\`\`

Wait 1-2 minutes for deployment.

## Step 4: Update Flutter App (3 minutes)

### Verify Dependencies
Your `pubspec.yaml` should have:
\`\`\`yaml
dependencies:
  cloud_functions: ^4.6.0
\`\`\`

If not, add it and run:
\`\`\`bash
flutter pub get
\`\`\`

### Files Already Created
The following files are already in your project:
- `lib/services/ai_service.dart` - AI service
- `lib/providers/chat_provider.dart` - Updated with AI support
- `lib/screens/conversation_screen.dart` - Updated with typing indicator

## Step 5: Test It! (1 minute)

### Run the App
\`\`\`bash
flutter run -d web-server
\`\`\`

### Test the Chatbot
1. Open the app in your browser
2. Navigate to Chat tab
3. Click "Dr. Wellness" (the one with 👨‍⚕️ emoji)
4. Send a message: "I'm feeling tired today"
5. Wait 2-3 seconds
6. You should see an AI response!

## Example Conversations to Try

**Health Advice:**
- "I'm feeling tired today"
- "How can I sleep better?"
- "What's a good workout routine?"

**Motivation:**
- "I'm struggling to stay motivated"
- "I missed my workout today"

**Questions:**
- "How many steps should I aim for?"
- "Is 7 hours of sleep enough?"

## Troubleshooting

### "Function not found"
\`\`\`bash
# Check if function is deployed
firebase functions:list

# Redeploy if needed
firebase deploy --only functions
\`\`\`

### "OpenAI API error"
\`\`\`bash
# Verify API key is set
firebase functions:config:get

# If empty, set it again
firebase functions:config:set openai.key="YOUR_KEY"
firebase deploy --only functions
\`\`\`

### "Permission denied"
Enable anonymous auth in Firebase:
1. Firebase Console → Authentication
2. Sign-in method → Anonymous → Enable

### Response is slow
Normal! OpenAI takes 2-5 seconds. The typing indicator shows it's working.

## Cost Tracking

### OpenAI Costs
- Free tier: $5 credit (lasts ~2500 messages)
- After free tier: ~$0.0002 per message
- 1000 messages = $0.20

### Firebase Costs
- Free tier: 125K function calls/month
- Firestore: 50K reads/day free
- More than enough for development!

## Next Steps

Once it's working:
1. Add authentication (Firebase Auth)
2. Implement message limits for free users
3. Add health data analysis
4. Create premium features
5. Add push notifications

## Need Help?

Check the full guide in `AI_CHATBOT_GUIDE.md` for:
- Detailed explanations
- Security best practices
- Advanced features
- Alternative AI services
