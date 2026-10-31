/// ==============================================================================
/// DỊCH VỤ QUẢN LÝ CHUỖI KỶ LUẬT & TIẾN ĐỘ HỌC TẬP (STREAK SERVICE)
/// Phụ trách: Lê Anh Tuấn (2151060296) - Mục Checklist 2 & 6
/// ==============================================================================

import '../models/user_progress_model.dart';

class StreakUpdateResult {
  final UserProgressModel updatedProgress;
  final bool isStreakIncreased;
  final bool wasFreezeUsed;
  final bool isGoalAchievedThisSession;
  final String statusMessage;

  StreakUpdateResult({
    required this.updatedProgress,
    required this.isStreakIncreased,
    required this.wasFreezeUsed,
    required this.isGoalAchievedThisSession,
    required this.statusMessage,
  });
}

class StreakService {
  /// Cập nhật chuỗi ngày và tiến độ học tập sau một phiên luyện phát âm
  StreakUpdateResult recordPracticeSession({
    required UserProgressModel current,
    required int sessionMinutes,
    required int wordsCount,
    DateTime? practiceTime,
  }) {
    final now = practiceTime ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = current.currentStreak;
    int longest = current.longestStreak;
    int freezeCount = current.streakFreezeCount;
    bool streakIncreased = false;
    bool freezeUsed = false;
    String message = '';

    int todayMinutes = current.todayMinutesLearned;
    int todayWords = current.todayWordsPracticed;

    if (current.lastPracticeDate == null) {
      // Ngày học đầu tiên của người dùng
      newStreak = 1;
      longest = 1;
      streakIncreased = true;
      todayMinutes = current.todayMinutesLearned + sessionMinutes;
      todayWords = current.todayWordsPracticed + wordsCount;
      message = '🎉 Chúc mừng bạn đã khởi động chuỗi ngày học đầu tiên!';
    } else {
      final lastDate = DateTime(
        current.lastPracticeDate!.year,
        current.lastPracticeDate!.month,
        current.lastPracticeDate!.day,
      );
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff == 0) {
        // Cùng một ngày: Cộng dồn thời gian và số từ, giữ nguyên chuỗi
        todayMinutes += sessionMinutes;
        todayWords += wordsCount;
        message = '💪 Bạn đang duy trì phong độ rất tốt trong hôm nay!';
      } else if (daysDiff == 1) {
        // Ngày liền kề tiếp theo: Tăng chuỗi Streak thêm 1
        newStreak += 1;
        streakIncreased = true;
        todayMinutes = sessionMinutes;
        todayWords = wordsCount;
        if (newStreak > longest) {
          longest = newStreak;
        }
        message = '🔥 Tuyệt vời! Chuỗi của bạn đã tăng lên $newStreak ngày liên tiếp!';
      } else if (daysDiff == 2 && freezeCount > 0) {
        // Bỏ lỡ 1 ngày nhưng còn lượt Đóng băng chuỗi (Freeze)
        freezeCount -= 1;
        freezeUsed = true;
        newStreak += 1;
        todayMinutes = sessionMinutes;
        todayWords = wordsCount;
        message = '🛡️ Khiên bảo vệ (Streak Freeze) đã cứu chuỗi ngày của bạn!';
      } else {
        // Đứt chuỗi: Reset lại về 1
        newStreak = 1;
        todayMinutes = sessionMinutes;
        todayWords = wordsCount;
        message = '🌱 Bắt đầu lại chuỗi mới. Đừng bỏ cuộc bạn nhé!';
      }
    }

    final updated = current.copyWith(
      currentStreak: newStreak,
      longestStreak: longest,
      lastPracticeDate: today,
      streakFreezeCount: freezeCount,
      todayMinutesLearned: todayMinutes,
      todayWordsPracticed: todayWords,
    );

    final goalAchievedNow = !current.isDailyGoalCompleted && updated.isDailyGoalCompleted;

    return StreakUpdateResult(
      updatedProgress: updated,
      isStreakIncreased: streakIncreased,
      wasFreezeUsed: freezeUsed,
      isGoalAchievedThisSession: goalAchievedNow,
      statusMessage: message,
    );
  }

  /// Kiểm tra trạng thái chuỗi ngày học để gửi thông báo nhắc nhở thông minh
  String checkStreakRiskStatus(UserProgressModel progress, DateTime currentTime) {
    if (progress.lastPracticeDate == null) {
      return 'Chưa bắt đầu chuỗi ngày học';
    }

    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final lastDate = DateTime(
      progress.lastPracticeDate!.year,
      progress.lastPracticeDate!.month,
      progress.lastPracticeDate!.day,
    );
    final daysDiff = today.difference(lastDate).inDays;

    if (daysDiff == 0) {
      return 'SAFE'; // Hôm nay đã học, an toàn
    } else if (daysDiff == 1) {
      if (currentTime.hour >= 20) {
        return 'CRITICAL_RISK'; // Sau 20:00 chưa học, sắp mất chuỗi!
      }
      return 'WARNING'; // Cần nhắc học hôm nay
    } else {
      return 'BROKEN'; // Đã quá hạn chuỗi
    }
  }
}
