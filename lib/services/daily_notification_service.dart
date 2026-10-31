/// ==============================================================================
/// HỆ THỐNG THÔNG BÁO NHẮC NHỞ LUYỆN TẬP HẰNG NGÀY (DAILY NOTIFICATION SERVICE)
/// Phụ trách: Lê Anh Tuấn (2151060296) - Mục Checklist 6
/// ==============================================================================

class NotificationSchedule {
  final int hour;
  final int minute;
  final List<String> repeatDays;
  final bool isEnabled;

  NotificationSchedule({
    this.hour = 20,
    this.minute = 0,
    this.repeatDays = const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
    this.isEnabled = true,
  });
}

class DailyNotificationService {
  NotificationSchedule _currentSchedule = NotificationSchedule();

  NotificationSchedule get currentSchedule => _currentSchedule;

  /// Thiết lập lịch nhắc nhở hàng ngày (Local Push Notification)
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    List<String>? repeatDays,
  }) async {
    _currentSchedule = NotificationSchedule(
      hour: hour,
      minute: minute,
      repeatDays: repeatDays ?? _currentSchedule.repeatDays,
      isEnabled: true,
    );
    // Trong Flutter: Sử dụng FlutterLocalNotificationsPlugin.zonedSchedule
  }

  /// Bắn thông báo khẩn cấp cứu chuỗi Streak (Smart Streak Warning)
  Future<String> triggerStreakUrgentWarning({
    required int currentStreak,
    required bool hasFreezeLeft,
  }) async {
    if (hasFreezeLeft) {
      return '⚠️ Bạn ơi, đừng quên luyện phát âm hôm nay nhé! Bạn còn 1 khiên bảo vệ chuỗi $currentStreak ngày.';
    } else {
      return '🔥 Cảnh báo khẩn cấp: Chỉ còn vài giờ nữa chuỗi $currentStreak ngày của bạn sẽ bị mất! Hãy học ngay 5 phút.';
    }
  }

  /// Bắn thông báo chúc mừng đạt mốc chuỗi mới
  String createStreakMilestoneNotification(int streakDays) {
    if (streakDays == 7) {
      return '🏆 Đẳng cấp! Bạn đã hoàn thành 1 tuần kỷ luật trọn vẹn (Chuỗi 7 ngày)!';
    } else if (streakDays == 30) {
      return '👑 Xuất chúng! 30 ngày kiên trì liên tục - Bạn đã hình thành phản xạ phát âm!';
    } else {
      return '🔥 Chuỗi ngày học tập của bạn vừa tăng lên $streakDays ngày liên tục!';
    }
  }
}
