/// ==============================================================================
/// MÔ HÌNH DỮ LIỆU TIẾN ĐỘ HỌC TẬP & KỶ LUẬT (USER PROGRESS & STREAK)
/// Phụ trách: Lê Anh Tuấn (2151060296) - Phân hệ Theo dõi Kỷ luật & Streak
/// ==============================================================================

class UserProgressModel {
  final String userId;
  final String displayName;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPracticeDate;
  final int streakFreezeCount;
  final int dailyGoalMinutes;
  final int dailyGoalWords;
  final int todayMinutesLearned;
  final int todayWordsPracticed;

  UserProgressModel({
    required this.userId,
    required this.displayName,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPracticeDate,
    this.streakFreezeCount = 1,
    this.dailyGoalMinutes = 15,
    this.dailyGoalWords = 10,
    this.todayMinutesLearned = 0,
    this.todayWordsPracticed = 0,
  });

  /// Kiểm tra xem người dùng đã hoàn thành mục tiêu ngày hôm nay chưa
  bool get isDailyGoalCompleted =>
      todayMinutesLearned >= dailyGoalMinutes || todayWordsPracticed >= dailyGoalWords;

  /// Tỷ lệ phần trăm hoàn thành mục tiêu ngày (0.0 đến 100.0%)
  double get goalCompletionPercentage {
    if (dailyGoalMinutes <= 0) return 100.0;
    final pct = (todayMinutesLearned / dailyGoalMinutes) * 100.0;
    return pct > 100.0 ? 100.0 : double.parse(pct.toStringAsFixed(1));
  }

  /// Tạo bản sao với các thuộc tính cập nhật (copyWith)
  UserProgressModel copyWith({
    String? userId,
    String? displayName,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPracticeDate,
    int? streakFreezeCount,
    int? dailyGoalMinutes,
    int? dailyGoalWords,
    int? todayMinutesLearned,
    int? todayWordsPracticed,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      streakFreezeCount: streakFreezeCount ?? this.streakFreezeCount,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      dailyGoalWords: dailyGoalWords ?? this.dailyGoalWords,
      todayMinutesLearned: todayMinutesLearned ?? this.todayMinutesLearned,
      todayWordsPracticed: todayWordsPracticed ?? this.todayWordsPracticed,
    );
  }

  /// Chuyển đổi từ Map (SQLite / JSON)
  factory UserProgressModel.fromMap(Map<String, dynamic> map) {
    return UserProgressModel(
      userId: map['userId'] ?? map['id'] ?? '',
      displayName: map['displayName'] ?? map['display_name'] ?? 'Học viên',
      currentStreak: map['currentStreak'] ?? map['current_streak'] ?? 0,
      longestStreak: map['longestStreak'] ?? map['longest_streak'] ?? 0,
      lastPracticeDate: map['lastPracticeDate'] != null
          ? DateTime.tryParse(map['lastPracticeDate'])
          : null,
      streakFreezeCount: map['streakFreezeCount'] ?? map['streak_freeze_count'] ?? 1,
      dailyGoalMinutes: map['dailyGoalMinutes'] ?? map['daily_goal_minutes'] ?? 15,
      dailyGoalWords: map['dailyGoalWords'] ?? map['daily_goal_words'] ?? 10,
      todayMinutesLearned: map['todayMinutesLearned'] ?? 0,
      todayWordsPracticed: map['todayWordsPracticed'] ?? 0,
    );
  }

  /// Chuyển đổi thành Map để lưu vào CSDL
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_practice_date': lastPracticeDate?.toIso8601String().split('T')[0],
      'streak_freeze_count': streakFreezeCount,
      'daily_goal_minutes': dailyGoalMinutes,
      'daily_goal_words': dailyGoalWords,
    };
  }
}
