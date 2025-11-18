import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // ✅ Add alias
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart' as app_auth; // ✅ Add alias
import '../models/message.dart'; // ✅ Import Conversation model
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
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 28),
                    color: AppColors.primary,
                    onPressed: () => _showNewChatDialog(context),
                  ),
                ],
              ),
            ),

            // AI Assistants Section
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('AI Assistants', style: AppTextStyles.heading2),
              ),
            ),

            // Dr. Wellness (Free AI)
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 4),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text('👨‍⚕️', style: TextStyle(fontSize: 24)),
                  ),
                ),
                title:
                    const Text('Dr. Wellness', style: AppTextStyles.heading3),
                subtitle: const Text('Your basic health companion',
                    style: AppTextStyles.caption),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final provider = context.read<ChatProvider>();
                  await provider.ensureAIConversationExists();

                  await Future.delayed(const Duration(milliseconds: 500));

                  try {
                    final aiConv = provider.conversations.firstWhere(
                      (c) => c.isAI && !c.isPremiumAI,
                    );
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ConversationScreen(conversation: aiConv),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('❌ Dr. Wellness conversation not found');
                  }
                },
              ),
            ),

            // Health Guru (Premium AI)
            Consumer<app_auth.AuthProvider>( // ✅ Use alias
              builder: (context, authProvider, _) {
                final isPremium = authProvider.isPremium ?? false; 

                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isPremium
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.secondary.withOpacity(0.1),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPremium
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPremium
                              ? [AppColors.primary, AppColors.secondary]
                              : [Colors.grey[300]!, Colors.grey[400]!],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: isPremium
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: const Center(
                        child: Text('🤖', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          'Health Guru',
                          style: AppTextStyles.heading3.copyWith(
                            color: isPremium ? AppColors.text : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: isPremium
                                ? const LinearGradient(
                                    colors: [Colors.amber, Colors.orange])
                                : null,
                            color: isPremium ? null : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PREMIUM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      isPremium
                          ? 'Advanced AI with memory ✨'
                          : 'Unlock with Premium 🔒',
                      style: TextStyle(
                        color: isPremium
                            ? AppColors.textSecondary
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Icon(
                      isPremium ? Icons.arrow_forward_ios : Icons.lock,
                      size: 16,
                      color: isPremium ? AppColors.text : Colors.grey,
                    ),
                    onTap: () async {
                      if (!isPremium) {
                        _showPremiumDialog(context);
                        return;
                      }

                      final conversationId = await context
                          .read<ChatProvider>()
                          .getOrCreatePremiumAIConversation();

                      if (conversationId != null && context.mounted) {
                        await Future.delayed(
                            const Duration(milliseconds: 500));

                        final provider = context.read<ChatProvider>();
                        try {
                          final premiumConv = provider.conversations.firstWhere(
                            (c) => c.id == conversationId,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ConversationScreen(conversation: premiumConv),
                            ),
                          );
                        } catch (e) {
                          debugPrint('❌ Premium AI conversation not found yet');
                          // ✅ Create fallback conversation
                          final fallbackConv = Conversation(
                            id: conversationId,
                            name: 'Health Guru',
                            avatar: '🤖',
                            lastMessage: 'Start chatting...',
                            timestamp: DateTime.now(),
                            isAI: true,
                            isPremiumAI: true,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConversationScreen(
                                  conversation: fallbackConv),
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // Messages Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Messages', style: AppTextStyles.heading2),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Chat List
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, _) {
                  final userChats = provider.conversations
                      .where((conv) => !conv.isAI)
                      .toList();

                  if (userChats.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Start a new chat!',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    itemCount: userChats.length,
                    itemBuilder: (context, index) {
                      final conversation = userChats[index];
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

  Widget _buildChatItem(BuildContext context, Conversation conversation) {
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
                color: AppColors.secondary.withOpacity(0.1),
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
                  Text(conversation.name, style: AppTextStyles.heading3),
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

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: [Colors.amber, Colors.orange]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('👑', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            const Text('Premium Feature'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Guru is an advanced AI assistant available for Premium members only.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text('Premium Benefits:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildBenefit('🧠 Conversation memory & context'),
            _buildBenefit('💪 Personalized health advice'),
            _buildBenefit('💬 Unlimited AI conversations'),
            _buildBenefit('📊 Advanced health insights'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Go to Profile → Upgrade to Premium to unlock Health Guru 👑'),
                  duration: Duration(seconds: 3),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Go to Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Start New Chat',
                        style: AppTextStyles.heading2),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No users found'));
                      }

                      final currentUserId =
                          firebase_auth.FirebaseAuth.instance.currentUser?.uid; // ✅ Use alias
                      final searchQuery = searchController.text.toLowerCase();

                      final filteredUsers = snapshot.data!.docs.where((doc) {
                        if (doc.id == currentUserId) return false;

                        final userData = doc.data() as Map<String, dynamic>;
                        final privacy =
                            userData['privacySettings'] as Map<String, dynamic>?;
                        final showInSearch = privacy?['showInSearch'] ?? true;
                        final profilePublic = privacy?['profilePublic'] ?? true;

                        if (!showInSearch || !profilePublic) return false;

                        if (searchQuery.isNotEmpty) {
                          final firstname = (userData['firstname'] ?? '')
                              .toString()
                              .toLowerCase();
                          final lastname = (userData['lastname'] ?? '')
                              .toString()
                              .toLowerCase();
                          final email =
                              (userData['email'] ?? '').toString().toLowerCase();
                          return firstname.contains(searchQuery) ||
                              lastname.contains(searchQuery) ||
                              email.contains(searchQuery);
                        }

                        return true;
                      }).toList();

                      if (filteredUsers.isEmpty) {
                        return Center(
                          child: Text(
                            searchQuery.isEmpty
                                ? 'No users available'
                                : 'No users found matching "$searchQuery"',
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final userDoc = filteredUsers[index];
                          final userData =
                              userDoc.data() as Map<String, dynamic>;
                          final userId = userDoc.id;
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
                              child: Center(
                                child: Text(
                                  firstName.isNotEmpty
                                      ? firstName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(displayName),
                            subtitle: Text(userData['email'] ?? ''),
                            onTap: () async {
                              Navigator.pop(dialogContext);

                              final conversationId = await dialogContext
                                  .read<ChatProvider>()
                                  .createConversation(userId);

                              if (conversationId == null) {
                                if (dialogContext.mounted) {
                                  ScaffoldMessenger.of(dialogContext)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Cannot message this user 🔒'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                                return;
                              }

                              if (dialogContext.mounted) {
                                final conversation = dialogContext
                                    .read<ChatProvider>()
                                    .conversations
                                    .firstWhere(
                                        (conv) => conv.id == conversationId);

                                Navigator.push(
                                  dialogContext,
                                  MaterialPageRoute(
                                    builder: (_) => ConversationScreen(
                                        conversation: conversation),
                                  ),
                                );
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
      ),
    );
  }
}