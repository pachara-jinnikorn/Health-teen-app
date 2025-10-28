import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/community_provider.dart';
import '../utils/constants.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(post.avatar, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.author, style: AppTextStyles.heading3),
                    Text(post.timeAgo, style: AppTextStyles.caption), // ✅ Use timeAgo
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Content
          Text(post.content, style: AppTextStyles.body),
          
          const SizedBox(height: AppSpacing.md),
          
          // Actions
          Row(
            children: [
              IconButton(
                icon: Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : AppColors.textSecondary,
                ),
                onPressed: () {
                  context.read<CommunityProvider>().toggleLike(post.id);
                },
              ),
              Text('${post.likes}', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text('${post.comments}', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.share_outlined, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}