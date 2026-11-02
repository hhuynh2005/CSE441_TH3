/// ==============================================================================
/// DỊCH VỤ QUẢN LÝ CHUỖI KỶ LUẬT & TIẾN ĐỘ HỌC TẬP (STREAK SERVICE)
/// Phụ trách: Lê Anh Tuấn (2151060296) - Mục Checklist 2 & 6
/// Bài tập thực hành 3 (TH3) - Nhóm 16
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

class DisciplineRank {
  final String title;
  final String description;
  final int level;
  final String badgeIcon;

  const DisciplineRank({
    required this.title,
    required this.description,
    required this.level,
    required this.badgeIcon,
  });
}

class DayProgressStatus {
  final DateTime date;
  final String dayLabel; // T2, T3, T4, T5, T6, T7, CN
  final bool isPracticed;
  final bool isToday;
  final bool isFuture;

  DayProgressStatus({
    required this.date,
    required this.dayLabel,
    required this.isPracticed,
    required this.isToday,
    required this.isFuture,
  });
}

class MilestoneTarget {
  final int targetDays;
  final int remainingDays;
  final double progressPercent;
  final String rewardTitle;
  final String icon;

  const MilestoneTarget({
    required this.targetDays,
    required this.remainingDays,
    required this.progressPercent,
    required this.rewardTitle,
    required this.icon,
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
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
        if (newStreak > longest) {
          longest = newStreak;
        }
        message = '🛡️ Khiên bảo vệ (Streak Freeze) đã cứu chuỗi ngày của bạn!';
      } else {
        // Đứt chuỗi: Reset lại về 1
        newStreak = 1;
        todayMinutes = sessionMinutes;
        todayWords = wordsCount;
        message = '🌱 Bắt đầu lại chuỗi mới. Đừng bỏ cuộc bạn nhé!';
      }
    }

    // Cập nhật danh sách lịch sử học tập
    final updatedHistory = List<String>.from(current.practiceDatesHistory);
    if (!updatedHistory.contains(todayStr)) {
      updatedHistory.add(todayStr);
    }

    final updated = current.copyWith(
      currentStreak: newStreak,
      longestStreak: longest,
      lastPracticeDate: today,
      streakFreezeCount: freezeCount,
      todayMinutesLearned: todayMinutes,
      todayWordsPracticed: todayWords,
      totalMinutesLearned: current.totalMinutesLearned + sessionMinutes,
      totalWordsPracticed: current.totalWordsPracticed + wordsCount,
      practiceDatesHistory: updatedHistory,
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

  /// Kiểm tra trạng thái rủi ro chuỗi ngày học để gửi thông báo nhắc nhở thông minh
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
      return 'SAFE'; // Hôm nay đã học, hoàn toàn an toàn
    } else if (daysDiff == 1) {
      if (currentTime.hour >= 20) {
        return 'CRITICAL_RISK'; // Sau 20:00 chưa học, cực kỳ khẩn cấp sắp mất chuỗi!
      }
      return 'WARNING'; // Cần nhắc học hôm nay
    } else {
      return 'BROKEN'; // Đã quá hạn chuỗi
    }
  }

  /// Xác định danh hiệu kỷ luật dựa trên độ dài của chuỗi ngày hiện tại
  DisciplineRank getDisciplineRank(int currentStreak) {
    if (currentStreak >= 30) {
      return const DisciplineRank(
        title: 'Huyền Thoại Bất Bại',
        description: 'Duy trì luyện phát âm bền bỉ hơn 30 ngày!',
        level: 5,
        badgeIcon: '👑',
      );
    } else if (currentStreak >= 14) {
      return const DisciplineRank(
        title: 'Bậc Thầy Phát Âm',
        description: 'Kỷ luật vững vàng qua 2 tuần liên tiếp!',
        level: 4,
        badgeIcon: '💎',
      );
    } else if (currentStreak >= 7) {
      return const DisciplineRank(
        title: 'Kỷ Luật Thép',
        description: 'Vượt qua 1 tuần trọn vẹn không bỏ lỡ ngày nào!',
        level: 3,
        badgeIcon: '⚔️',
      );
    } else if (currentStreak >= 3) {
      return const DisciplineRank(
        title: 'Chiến Binh Kiên Trì',
        description: 'Đang hình thành thói quen học tập tích cực!',
        level: 2,
        badgeIcon: '🔥',
      );
    } else {
      return const DisciplineRank(
        title: 'Tân Binh Luyện Âm',
        description: 'Những bước chân đầu tiên trên hành trình chinh phục tiếng Anh!',
        level: 1,
        badgeIcon: '🌱',
      );
    }
  }

  /// Cập nhật mục tiêu luyện tập hàng ngày (Daily Goals)
  UserProgressModel updateDailyGoals(
    UserProgressModel current, {
    int? minutes,
    int? words,
  }) {
    return current.copyWith(
      dailyGoalMinutes: minutes != null && minutes > 0 ? minutes : current.dailyGoalMinutes,
      dailyGoalWords: words != null && words > 0 ? words : current.dailyGoalWords,
    );
  }

  /// Thưởng thêm khiên bảo vệ chuỗi (Streak Freeze Shield)
  UserProgressModel addFreezeShield(UserProgressModel current, {int amount = 1}) {
    return current.copyWith(
      streakFreezeCount: current.streakFreezeCount + amount,
    );
  }

  /// Kích hoạt sử dụng khiên bảo vệ chuỗi thủ công
  UserProgressModel? useFreezeStreakManually(UserProgressModel current) {
    if (current.streakFreezeCount <= 0) return null;
    return current.copyWith(
      streakFreezeCount: current.streakFreezeCount - 1,
    );
  }

  /// Lấy danh sách trạng thái học tập 7 ngày trong tuần hiện tại (Thứ 2 đến Chủ Nhật)
  List<DayProgressStatus> getWeeklyCalendarStatus(
    UserProgressModel progress, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Tìm ngày Thứ 2 đầu tuần (weekday: 1 là Thứ 2, 7 là Chủ Nhật)
    final monday = today.subtract(Duration(days: today.weekday - 1));

    final dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final List<DayProgressStatus> weekStatus = [];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final isToday = date.isAtSameMomentAs(today);
      final isFuture = date.isAfter(today);

      // Kiểm tra xem ngày này đã học chưa
      final isPracticed = progress.practiceDatesHistory.contains(dateStr) ||
          (progress.lastPracticeDate != null &&
              progress.lastPracticeDate!.year == date.year &&
              progress.lastPracticeDate!.month == date.month &&
              progress.lastPracticeDate!.day == date.day);

      weekStatus.add(DayProgressStatus(
        date: date,
        dayLabel: dayLabels[i],
        isPracticed: isPracticed,
        isToday: isToday,
        isFuture: isFuture,
      ));
    }

    return weekStatus;
  }

  /// Xác định mốc chuỗi kế tiếp cần chinh phục và số ngày còn lại
  MilestoneTarget getNextMilestoneTarget(int currentStreak) {
    const milestones = [3, 7, 14, 30, 60, 100];
    int target = 100;
    String reward = 'Cúp Huyền Thoại';
    String icon = '🏆';

    for (final m in milestones) {
      if (currentStreak < m) {
        target = m;
        if (m == 3) {
          reward = 'Huy Hiệu Khởi Đầu';
          icon = '🌱';
        } else if (m == 7) {
          reward = 'Huy Hiệu 1 Tuần Kỷ Luật';
          icon = '🔥';
        } else if (m == 14) {
          reward = 'Huy Hiệu 2 Tuần Kiên Trì';
          icon = '💎';
        } else if (m == 30) {
          reward = 'Vương Miện 1 Tháng';
          icon = '👑';
        } else if (m == 60) {
          reward = 'Khiên Kim Cương';
          icon = '🛡️';
        }
        break;
      }
    }

    final remaining = target - currentStreak;
    final pct = (currentStreak / target) * 100.0;
    return MilestoneTarget(
      targetDays: target,
      remainingDays: remaining > 0 ? remaining : 0,
      progressPercent: pct.clamp(0.0, 100.0),
      rewardTitle: reward,
      icon: icon,
    );
  }

  /// Khôi phục chuỗi ngày đã mất khi học viên vượt qua thử thách bù bài học
  UserProgressModel recoverBrokenStreak(
    UserProgressModel current, {
    required int originalStreak,
  }) {
    final restoredStreak = originalStreak > 0 ? originalStreak : 1;
    final longest = restoredStreak > current.longestStreak ? restoredStreak : current.longestStreak;
    return current.copyWith(
      currentStreak: restoredStreak,
      longestStreak: longest,
      recoveredStreakCount: current.recoveredStreakCount + 1,
    );
  }

  /// Tính tỷ lệ % duy trì kỷ luật trong chu kỳ (mặc định 30 ngày gần nhất)
  double calculateDisciplineConsistencyRate(
    UserProgressModel progress, {
    int periodDays = 30,
  }) {
    if (periodDays <= 0 || progress.practiceDatesHistory.isEmpty) return 0.0;
    final count = progress.practiceDatesHistory.length;
    final rate = (count / periodDays) * 100.0;
    return rate > 100.0 ? 100.0 : double.parse(rate.toStringAsFixed(1));
  }
}
