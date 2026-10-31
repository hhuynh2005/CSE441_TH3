/// ==============================================================================
/// WIDGET HUY HIỆU CHUỖI NGÀY HỌC LIÊN TỤC (STREAK BADGE WIDGET)
/// Phụ trách: Lê Anh Tuấn (2151060296) - Mục Checklist 2 & 6
/// ==============================================================================

import 'package:flutter/material.dart';
import '../models/user_progress_model.dart';

class StreakBadgeWidget extends StatelessWidget {
  final UserProgressModel progress;

  const StreakBadgeWidget({Key? key, required this.progress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.yellowAccent, size: 32),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${progress.currentStreak} NGÀY',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Kỷ lục: ${progress.longestStreak} ngày | 🛡️ ${progress.streakFreezeCount} khiên',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
