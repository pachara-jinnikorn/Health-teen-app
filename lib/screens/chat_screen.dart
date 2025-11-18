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
                  // ✅ Button to start new chat
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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

  // ✅ Show dialog with Privacy filtering and Search
  void _showNewChatDialog(BuildContext context) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
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
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  onChanged: (value) => setState(() {}),
                ),

                const SizedBox(height: AppSpacing.md),

                // User list
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
                          FirebaseAuth.instance.currentUser?.uid;
                      final searchQuery = searchController.text.toLowerCase();

                      // ✅ Filter users by Privacy Settings and Search Query
                      final filteredUsers = snapshot.data!.docs.where((doc) {
                        if (doc.id == currentUserId) {
                          debugPrint('⏭️ Skipping current user');
                          return false;
                        }

                        final userData = doc.data() as Map<String, dynamic>;

                        debugPrint(
                            '👤 Checking user: ${userData['firstname']} ${userData['lastname']}');
                        debugPrint(
                            '   Privacy: ${userData['privacySettings']}');

                        // ✅ Check Privacy Settings (ถ้าไม่มี ให้ถือว่าเป็น true)
                        final privacy = userData['privacySettings']
                            as Map<String, dynamic>?;

                        final showInSearch = privacy?['showInSearch'] ?? true;
                        final profilePublic = privacy?['profilePublic'] ?? true;

                        if (!showInSearch) {
                          debugPrint('   ❌ Hidden from search');
                          return false;
                        }

                        if (!profilePublic) {
                          debugPrint('   ❌ Private profile');
                          return false;
                        }

                        // Filter by search query (only if user is typing)
                        if (searchQuery.isNotEmpty) {
                          final firstname = (userData['firstname'] ?? '')
                              .toString()
                              .toLowerCase();
                          final lastname = (userData['lastname'] ?? '')
                              .toString()
                              .toLowerCase();
                          final email = (userData['email'] ?? '')
                              .toString()
                              .toLowerCase();

                          final matches = firstname.contains(searchQuery) ||
                              lastname.contains(searchQuery) ||
                              email.contains(searchQuery);

                          debugPrint('   🔍 Search match: $matches');
                          return matches;
                        }

                        debugPrint('   ✅ Showing user');
                        return true;
                      }).toList();

                      debugPrint(
                          '📋 Total filtered users: ${filteredUsers.length}');

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

                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Creating conversation...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );

                              // ✅ Create conversation (Privacy check in ChatProvider)
                              final conversationId = await dialogContext
                                  .read<ChatProvider>()
                                  .createConversation(userId);

                              if (conversationId == null) {
                                // ✅ Show error if cannot create chat
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
                                      conversation: conversation,
                                    ),
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
