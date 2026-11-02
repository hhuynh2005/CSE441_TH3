import 'package:test/test.dart';
import '../lib/services/streak_service.dart';
import '../lib/services/daily_notification_service.dart';
import '../lib/models/user_progress_model.dart';

void main() {
  group('StreakService Tests (Mục 2 & 6 - Lê Anh Tuấn)', () {
    late StreakService streakService;
    late DailyNotificationService notificationService;

    setUp(() {
      streakService = StreakService();
      notificationService = DailyNotificationService();
    });

    test('TC-01: Khởi động chuỗi học ngày đầu tiên (Streak = 1)', () {
      final initialUser = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        currentStreak: 0,
        lastPracticeDate: null,
      );

      final result = streakService.recordPracticeSession(
        current: initialUser,
        sessionMinutes: 10,
        wordsCount: 5,
        practiceTime: DateTime(2026, 11, 1),
      );

      expect(result.updatedProgress.currentStreak, equals(1));
      expect(result.updatedProgress.longestStreak, equals(1));
      expect(result.updatedProgress.totalMinutesLearned, equals(10));
      expect(result.updatedProgress.totalWordsPracticed, equals(5));
      expect(result.isStreakIncreased, isTrue);
    });

    test('TC-02: Học tiếp trong cùng một ngày: giữ nguyên streak, cộng dồn số phút', () {
      final existingUser = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        currentStreak: 3,
        lastPracticeDate: DateTime(2026, 11, 1),
        todayMinutesLearned: 10,
        todayWordsPracticed: 5,
        totalMinutesLearned: 30,
        totalWordsPracticed: 20,
      );

      final result = streakService.recordPracticeSession(
        current: existingUser,
        sessionMinutes: 15,
        wordsCount: 10,
        practiceTime: DateTime(2026, 11, 1),
      );

      expect(result.updatedProgress.currentStreak, equals(3));
      expect(result.updatedProgress.todayMinutesLearned, equals(25));
      expect(result.updatedProgress.todayWordsPracticed, equals(15));
      expect(result.updatedProgress.totalMinutesLearned, equals(45));
      expect(result.updatedProgress.totalWordsPracticed, equals(30));
      expect(result.isStreakIncreased, isFalse);
    });

    test('TC-03: Học liên tục vào ngày hôm sau: tăng chuỗi Streak lên 1', () {
      final existingUser = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        currentStreak: 5,
        longestStreak: 5,
        lastPracticeDate: DateTime(2026, 11, 1),
      );

      final result = streakService.recordPracticeSession(
        current: existingUser,
        sessionMinutes: 15,
        wordsCount: 12,
        practiceTime: DateTime(2026, 11, 2),
      );

      expect(result.updatedProgress.currentStreak, equals(6));
      expect(result.updatedProgress.longestStreak, equals(6));
      expect(result.isStreakIncreased, isTrue);
    });

    test('TC-04: Bỏ lỡ 1 ngày nhưng có Streak Freeze: chuỗi được bảo vệ', () {
      final existingUser = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        currentStreak: 10,
        streakFreezeCount: 1, // Còn 1 khiên
        lastPracticeDate: DateTime(2026, 11, 1),
      );

      // Học viên quay lại vào ngày 11/3 (bỏ lỡ ngày 11/2)
      final result = streakService.recordPracticeSession(
        current: existingUser,
        sessionMinutes: 20,
        wordsCount: 15,
        practiceTime: DateTime(2026, 11, 3),
      );

      expect(result.wasFreezeUsed, isTrue);
      expect(result.updatedProgress.streakFreezeCount, equals(0)); // Đã dùng mất 1 khiên
      expect(result.updatedProgress.currentStreak, equals(11)); // Vẫn giữ và tăng chuỗi
    });

    test('TC-05: Bỏ lỡ ngày và hết khiên Freeze: reset chuỗi về 1', () {
      final existingUser = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        currentStreak: 10,
        streakFreezeCount: 0, // Hết khiên
        lastPracticeDate: DateTime(2026, 11, 1),
      );

      final result = streakService.recordPracticeSession(
        current: existingUser,
        sessionMinutes: 15,
        wordsCount: 10,
        practiceTime: DateTime(2026, 11, 3),
      );

      expect(result.wasFreezeUsed, isFalse);
      expect(result.updatedProgress.currentStreak, equals(1)); // Reset chuỗi
    });

    test('TC-06: Hoàn thành mục tiêu ngày (Daily Goal) kích hoạt cờ thành công', () {
      final user = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        dailyGoalMinutes: 15,
        todayMinutesLearned: 10,
      );

      final result = streakService.recordPracticeSession(
        current: user,
        sessionMinutes: 10, // Tổng 20 phút >= 15 phút mục tiêu
        wordsCount: 5,
        practiceTime: DateTime(2026, 11, 1),
      );

      expect(result.isGoalAchievedThisSession, isTrue);
      expect(result.updatedProgress.isDailyGoalCompleted, isTrue);
      expect(result.updatedProgress.goalCompletionPercentage, equals(100.0));
    });

    test('TC-07: Kiểm tra cấp độ kỷ luật (Discipline Rank) theo độ dài chuỗi', () {
      expect(streakService.getDisciplineRank(1).title, equals('Tân Binh Luyện Âm'));
      expect(streakService.getDisciplineRank(4).title, equals('Chiến Binh Kiên Trì'));
      expect(streakService.getDisciplineRank(8).title, equals('Kỷ Luật Thép'));
      expect(streakService.getDisciplineRank(15).title, equals('Bậc Thầy Phát Âm'));
      expect(streakService.getDisciplineRank(35).title, equals('Huyền Thoại Bất Bại'));
    });

    test('TC-08: Kiểm tra trạng thái rủi ro chuỗi (Streak Risk Status)', () {
      final safeUser = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        lastPracticeDate: DateTime(2026, 11, 2),
      );
      // Ngày 2/11 đã học -> SAFE
      expect(
        streakService.checkStreakRiskStatus(safeUser, DateTime(2026, 11, 2, 10, 0)),
        equals('SAFE'),
      );

      // Ngày 3/11 buổi sáng chưa học -> WARNING
      expect(
        streakService.checkStreakRiskStatus(safeUser, DateTime(2026, 11, 3, 14, 0)),
        equals('WARNING'),
      );

      // Ngày 3/11 sau 20:00 chưa học -> CRITICAL_RISK (cảnh báo nguy cấp)
      expect(
        streakService.checkStreakRiskStatus(safeUser, DateTime(2026, 11, 3, 20, 30)),
        equals('CRITICAL_RISK'),
      );

      // Ngày 5/11 (cách 3 ngày) -> BROKEN
      expect(
        streakService.checkStreakRiskStatus(safeUser, DateTime(2026, 11, 5, 8, 0)),
        equals('BROKEN'),
      );
    });

    test('TC-09: Kiểm tra tính toán lịch tuần 7 ngày (Weekly Calendar Status)', () {
      final user = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        lastPracticeDate: DateTime(2026, 11, 1),
        practiceDatesHistory: ['2026-10-29', '2026-10-31'],
      );

      final weekStatus = streakService.getWeeklyCalendarStatus(
        user,
        referenceDate: DateTime(2026, 11, 1), // Chủ Nhật 1/11/2026
      );

      expect(weekStatus.length, equals(7));
      expect(weekStatus[0].dayLabel, equals('T2'));
      expect(weekStatus[6].dayLabel, equals('CN'));
      expect(weekStatus[6].isToday, isTrue);
    });

    test('TC-10: Cập nhật mục tiêu ngày và quản lý khiên Freeze Streak', () {
      final user = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        dailyGoalMinutes: 10,
        streakFreezeCount: 1,
      );

      final updatedGoals = streakService.updateDailyGoals(user, minutes: 25, words: 15);
      expect(updatedGoals.dailyGoalMinutes, equals(25));
      expect(updatedGoals.dailyGoalWords, equals(15));

      final withMoreShields = streakService.addFreezeShield(user, amount: 2);
      expect(withMoreShields.streakFreezeCount, equals(3));

      final afterManualUse = streakService.useFreezeStreakManually(withMoreShields);
      expect(afterManualUse?.streakFreezeCount, equals(2));
    });

    test('TC-11: Kiểm tra thông báo kỷ lục chuỗi ngày và cảnh báo khẩn cấp', () async {
      final msg7 = notificationService.createStreakMilestoneNotification(7);
      expect(msg7.contains('7 ngày'), isTrue);

      final msg30 = notificationService.createStreakMilestoneNotification(30);
      expect(msg30.contains('30 ngày'), isTrue);

      final warningWithShield = await notificationService.triggerStreakUrgentWarning(
        currentStreak: 5,
        hasFreezeLeft: true,
      );
      expect(warningWithShield.contains('khiên bảo vệ'), isTrue);

      final warningWithoutShield = await notificationService.triggerStreakUrgentWarning(
        currentStreak: 5,
        hasFreezeLeft: false,
      );
      expect(warningWithoutShield.contains('Cảnh báo khẩn cấp'), isTrue);

      expect(notificationService.notificationHistory.isNotEmpty, isTrue);
    });
  });
}
