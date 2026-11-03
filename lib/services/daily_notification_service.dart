/// ==============================================================================
/// HỆ THỐNG THÔNG BÁO NHẮC NHỞ LUYỆN TẬP HẰNG NGÀY (DAILY NOTIFICATION SERVICE)
/// Phụ trách: Lê Anh Tuấn (2151060296) - Mục Checklist 6
/// Bài tập thực hành 3 (TH3) - Nhóm 16
/// ==============================================================================

import '../models/user_progress_model.dart';

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class NotificationSchedule {
  final int hour;
  final int minute;
  final List<String> repeatDays;
  final bool isEnabled;

  NotificationSchedule({
    this.hour = 20,
    this.minute = 0,
    this.repeatDays = const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
    this.isEnabled = true,
  });

  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class NotificationMessage {
  final String id;
  final String title;
  final String body;
  final DateTime sentAt;
  final String type; // DAILY_REMINDER, STREAK_WARNING, MILESTONE, GOAL_COMPLETED, WEEKEND_CHALLENGE
  final NotificationPriority priority;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
    required this.type,
    this.priority = NotificationPriority.normal,
  });
}

class DailyNotificationService {
  NotificationSchedule _currentSchedule = NotificationSchedule();
  final List<NotificationMessage> _notificationHistory = [];

  NotificationSchedule get currentSchedule => _currentSchedule;
  List<NotificationMessage> get notificationHistory => List.unmodifiable(_notificationHistory);

  /// Thiết lập lịch nhắc nhở hàng ngày (Local Push Notification)
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    List<String>? repeatDays,
    bool isEnabled = true,
  }) async {
    _currentSchedule = NotificationSchedule(
      hour: hour,
      minute: minute,
      repeatDays: repeatDays ?? _currentSchedule.repeatDays,
      isEnabled: isEnabled,
    );
  }

  /// Bắn thông báo khẩn cấp cứu chuỗi Streak (Smart Streak Warning)
  Future<String> triggerStreakUrgentWarning({
    required int currentStreak,
    required bool hasFreezeLeft,
  }) async {
    String msg;
    if (hasFreezeLeft) {
      msg = '⚠️ Bạn ơi, đừng quên luyện phát âm hôm nay nhé! Bạn còn 1 khiên bảo vệ chuỗi $currentStreak ngày.';
    } else {
      msg = '🔥 Cảnh báo khẩn cấp: Chỉ còn vài giờ nữa chuỗi $currentStreak ngày của bạn sẽ bị mất! Hãy học ngay 5 phút.';
    }

    _recordNotification(
      title: '🚨 Cứu Chuỗi Streak $currentStreak Ngày!',
      body: msg,
      type: 'STREAK_WARNING',
      priority: NotificationPriority.urgent,
    );

    return msg;
  }

  /// Tạo thông báo chúc mừng khi đạt các mốc chuỗi ngày quan trọng (Milestones)
  String createStreakMilestoneNotification(int streakDays) {
    String message;
    if (streakDays == 3) {
      message = '🔥 Tuyệt vời! Bạn đã bắt đầu hình thành thói quen với chuỗi 3 ngày liên tiếp!';
    } else if (streakDays == 7) {
      message = '🏆 Đẳng cấp! Bạn đã hoàn thành 1 tuần kỷ luật trọn vẹn (Chuỗi 7 ngày)!';
    } else if (streakDays == 14) {
      message = '💎 Xuất sắc! 2 tuần liên tục phát âm chuẩn mỗi ngày - Đột phá ngữ âm!';
    } else if (streakDays == 30) {
      message = '👑 Huyền thoại! 30 ngày kiên trì liên tục - Bạn đã hình thành phản xạ phát âm người bản xứ!';
    } else if (streakDays == 100) {
      message = '🚀 Kỷ lục vô tiền khoáng hậu! 100 ngày không ngừng nghỉ - Bạn là nguồn cảm hứng!';
    } else {
      message = '🔥 Chuỗi ngày học tập của bạn vừa tăng lên $streakDays ngày liên tục!';
    }

    _recordNotification(
      title: '🎉 Mốc Kỷ Lục Chuỗi Ngày!',
      body: message,
      type: 'MILESTONE',
      priority: NotificationPriority.high,
    );

    return message;
  }

  /// Tạo thông báo chúc mừng hoàn thành mục tiêu ngày
  String createGoalAchievedNotification(int minutesLearned) {
    final message = '🌟 Xuất sắc! Bạn đã hoàn thành trọn vẹn mục tiêu luyện tập $minutesLearned phút ngày hôm nay!';
    _recordNotification(
      title: '🎯 Mục Tiêu Ngày Đã Hoàn Thành!',
      body: message,
      type: 'GOAL_COMPLETED',
      priority: NotificationPriority.high,
    );
    return message;
  }

  /// Tạo thông báo thử thách duy trì chuỗi cuối tuần
  String createWeekendChallengeNotification() {
    const message = '🎯 Thử thách cuối tuần: Đừng để thứ Bảy & Chủ Nhật làm gián đoạn chuỗi kỷ luật phát âm của bạn!';
    _recordNotification(
      title: '⚡ Thử Thách Kỷ Luật Cuối Tuần',
      body: message,
      type: 'WEEKEND_CHALLENGE',
      priority: NotificationPriority.normal,
    );
    return message;
  }

  /// Tạo câu nói truyền cảm hứng ngẫu nhiên cho lời nhắc hàng ngày
  String generateDailyMotivationMessage(UserProgressModel progress) {
    final quotes = [
      '“Phát âm chuẩn tiếng Anh bắt đầu từ 5 phút luyện tập mỗi ngày!”',
      '“Duy trì chuỗi ngày là chìa khóa để nói tiếng Anh tự nhiên như người bản xứ.”',
      '“Chỉ còn một chút nữa là hoàn thành mục tiêu ngày hôm nay, cố lên nhé!”',
      '“Kỷ luật hôm nay, tự tin ngày mai. Hãy mở SpeakUp AI và luyện ngay!”',
    ];
    final index = progress.currentStreak % quotes.length;
    return quotes[index];
  }

  /// Mô phỏng bắn thông báo cục bộ và ghi nhận vào lịch sử
  NotificationMessage sendSimulatedNotification({
    required String title,
    required String body,
    String type = 'DAILY_REMINDER',
    NotificationPriority priority = NotificationPriority.normal,
  }) {
    return _recordNotification(
      title: title,
      body: body,
      type: type,
      priority: priority,
    );
  }

  NotificationMessage _recordNotification({
    required String title,
    required String body,
    required String type,
    NotificationPriority priority = NotificationPriority.normal,
  }) {
    final notification = NotificationMessage(
      id: 'noti_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      sentAt: DateTime.now(),
      type: type,
      priority: priority,
    );
    _notificationHistory.insert(0, notification);
    return notification;
  }
}
