/// ==============================================================================
/// MÔ HÌNH DỮ LIỆU TIẾN ĐỘ HỌC TẬP & KỶ LUẬT (USER PROGRESS & STREAK)
/// Phụ trách: Lê Anh Tuấn (2151060296) - Phân hệ Theo dõi Kỷ luật & Streak
/// Mục Checklist 2 & 6 - Bài tập thực hành 3 (TH3)
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
  final int totalMinutesLearned;
  final int totalWordsPracticed;
  final List<String> practiceDatesHistory;
  final bool isDailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;

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
    this.totalMinutesLearned = 0,
    this.totalWordsPracticed = 0,
    this.practiceDatesHistory = const [],
    this.isDailyReminderEnabled = true,
    this.reminderHour = 20,
    this.reminderMinute = 0,
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

  /// Tỷ lệ phần trăm hoàn thành số từ mục tiêu ngày (0.0 đến 100.0%)
  double get wordsCompletionPercentage {
    if (dailyGoalWords <= 0) return 100.0;
    final pct = (todayWordsPracticed / dailyGoalWords) * 100.0;
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
    int? totalMinutesLearned,
    int? totalWordsPracticed,
    List<String>? practiceDatesHistory,
    bool? isDailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
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
      totalMinutesLearned: totalMinutesLearned ?? this.totalMinutesLearned,
      totalWordsPracticed: totalWordsPracticed ?? this.totalWordsPracticed,
      practiceDatesHistory: practiceDatesHistory ?? this.practiceDatesHistory,
      isDailyReminderEnabled: isDailyReminderEnabled ?? this.isDailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }

  /// Chuyển đổi từ Map (SQLite / JSON)
  factory UserProgressModel.fromMap(Map<String, dynamic> map) {
    List<String> history = [];
    if (map['practiceDatesHistory'] != null) {
      if (map['practiceDatesHistory'] is List) {
        history = List<String>.from(map['practiceDatesHistory']);
      } else if (map['practiceDatesHistory'] is String) {
        history = (map['practiceDatesHistory'] as String).split(',').where((s) => s.isNotEmpty).toList();
      }
    }

    return UserProgressModel(
      userId: map['userId'] ?? map['id'] ?? '',
      displayName: map['displayName'] ?? map['display_name'] ?? 'Học viên',
      currentStreak: map['currentStreak'] ?? map['current_streak'] ?? 0,
      longestStreak: map['longestStreak'] ?? map['longest_streak'] ?? 0,
      lastPracticeDate: map['lastPracticeDate'] != null
          ? DateTime.tryParse(map['lastPracticeDate'].toString())
          : null,
      streakFreezeCount: map['streakFreezeCount'] ?? map['streak_freeze_count'] ?? 1,
      dailyGoalMinutes: map['dailyGoalMinutes'] ?? map['daily_goal_minutes'] ?? 15,
      dailyGoalWords: map['dailyGoalWords'] ?? map['daily_goal_words'] ?? 10,
      todayMinutesLearned: map['todayMinutesLearned'] ?? 0,
      todayWordsPracticed: map['todayWordsPracticed'] ?? 0,
      totalMinutesLearned: map['totalMinutesLearned'] ?? map['total_minutes_learned'] ?? 0,
      totalWordsPracticed: map['totalWordsPracticed'] ?? map['total_words_practiced'] ?? 0,
      practiceDatesHistory: history,
      isDailyReminderEnabled: map['isDailyReminderEnabled'] ?? true,
      reminderHour: map['reminderHour'] ?? 20,
      reminderMinute: map['reminderMinute'] ?? 0,
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
      'total_minutes_learned': totalMinutesLearned,
      'total_words_practiced': totalWordsPracticed,
      'practice_dates_history': practiceDatesHistory.join(','),
      'is_daily_reminder_enabled': isDailyReminderEnabled ? 1 : 0,
      'reminder_hour': reminderHour,
      'reminder_minute': reminderMinute,
    };
  }
}
