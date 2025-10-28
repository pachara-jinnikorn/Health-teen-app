import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import 'conversation_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with New Chat button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Health Teen', style: AppTextStyles.heading1),
                  // ✅ NEW: Button to start new chat
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 28),
                    color: AppColors.primary,
                    onPressed: () => _showNewChatDialog(context),
                  ),
                ],
              ),
            ),
            
            // Chat List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Chat', style: AppTextStyles.heading2),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, _) {
                  if (provider.conversations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text('Loading your chats...'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await provider.ensureAIConversationExists();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: provider.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = provider.conversations[index];
                      return _buildChatItem(context, conversation);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, conversation) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationScreen(conversation: conversation),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: conversation.isAI
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  conversation.avatar,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(conversation.name, style: AppTextStyles.heading3),
                      if (conversation.isAI) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'AI',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              _formatTime(conversation.timestamp),
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  // ✅ NEW: Show dialog to select a user to chat with
  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Start New Chat',
                    style: AppTextStyles.heading2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // User list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .limit(20)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No users found'),
                      );
                    }

                    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                    final users = snapshot.data!.docs
                        .where((doc) => doc.id != currentUserId)
                        .toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final userData = users[index].data() as Map<String, dynamic>;
                        final userId = users[index].id;
                        final firstName = userData['firstname'] ?? 'User';
                        final lastName = userData['lastname'] ?? '';
                        final displayName = lastName.isNotEmpty 
                            ? '$firstName $lastName' 
                            : firstName;

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text('👤', style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          title: Text(displayName),
                          subtitle: Text(userData['email'] ?? ''),
                          onTap: () async {
                            // Close the dialog
                            Navigator.pop(dialogContext);
                            
                            // Show loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Creating conversation...'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            
                            // Create conversation
                            final conversationId = await context
                                .read<ChatProvider>()
                                .createConversation(userId);
                            
                            if (conversationId != null) {
                              // Get the conversation details
                              final convDoc = await FirebaseFirestore.instance
                                  .collection('conversations')
                                  .doc(conversationId)
                                  .get();
                              
                              if (convDoc.exists && context.mounted) {
                                final conversation = convDoc.data();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConversationScreen(
                                      conversation: conversation,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}