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

    test('TC-12 (Đối soát Ma trận TC-02 trong KICH_BAN_KIEM_THU_TH3.md): Học Ngày 1, Ngày 2, bỏ ngày 3 có Freeze, ngày 4 học tiếp', () {
      // 1. Ngày 1: Bắt đầu học -> Streak = 1
      var user = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        currentStreak: 0,
        streakFreezeCount: 1,
        lastPracticeDate: null,
      );

      var r1 = streakService.recordPracticeSession(
        current: user,
        sessionMinutes: 10,
        wordsCount: 5,
        practiceTime: DateTime(2026, 11, 1),
      );
      expect(r1.updatedProgress.currentStreak, equals(1));

      // 2. Ngày 2: Học tiếp liền kề -> Streak = 2
      var r2 = streakService.recordPracticeSession(
        current: r1.updatedProgress,
        sessionMinutes: 10,
        wordsCount: 5,
        practiceTime: DateTime(2026, 11, 2),
      );
      expect(r2.updatedProgress.currentStreak, equals(2));
      expect(r2.updatedProgress.streakFreezeCount, equals(1));

      // 3. Ngày 3: Bỏ lỡ. Ngày 4 (11/4): Quay lại học, khiên Freeze tự động kích hoạt bảo vệ
      var r3 = streakService.recordPracticeSession(
        current: r2.updatedProgress,
        sessionMinutes: 15,
        wordsCount: 8,
        practiceTime: DateTime(2026, 11, 4),
      );
      expect(r3.wasFreezeUsed, isTrue);
      expect(r3.updatedProgress.streakFreezeCount, equals(0)); // Dùng hết 1 khiên
      expect(r3.updatedProgress.currentStreak, equals(3)); // Giữ và tăng lên 3
    });

    test('TC-13 (Đối soát Ma trận TC-03 trong KICH_BAN_KIEM_THU_TH3.md): Đặt mục tiêu 15 phút, học 3 phiên 5 phút đạt 100%', () {
      var user = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        dailyGoalMinutes: 15,
        todayMinutesLearned: 0,
      );

      // Phiên 1: 5 phút -> Chưa đạt (33.3%)
      var r1 = streakService.recordPracticeSession(
        current: user,
        sessionMinutes: 5,
        wordsCount: 3,
        practiceTime: DateTime(2026, 11, 1),
      );
      expect(r1.updatedProgress.isDailyGoalCompleted, isFalse);
      expect(r1.updatedProgress.todayMinutesLearned, equals(5));

      // Phiên 2: 5 phút nữa -> Tổng 10 phút, Chưa đạt (66.7%)
      var r2 = streakService.recordPracticeSession(
        current: r1.updatedProgress,
        sessionMinutes: 5,
        wordsCount: 3,
        practiceTime: DateTime(2026, 11, 1),
      );
      expect(r2.updatedProgress.isDailyGoalCompleted, isFalse);
      expect(r2.updatedProgress.todayMinutesLearned, equals(10));

      // Phiên 3: 5 phút nữa -> Tổng 15 phút, Đạt 100% mục tiêu ngày!
      var r3 = streakService.recordPracticeSession(
        current: r2.updatedProgress,
        sessionMinutes: 5,
        wordsCount: 4,
        practiceTime: DateTime(2026, 11, 1),
      );
      expect(r3.isGoalAchievedThisSession, isTrue);
      expect(r3.updatedProgress.isDailyGoalCompleted, isTrue);
      expect(r3.updatedProgress.todayMinutesLearned, equals(15));
      expect(r3.updatedProgress.goalCompletionPercentage, equals(100.0));
    });

    test('TC-14: Tính toán mục tiêu mốc tiếp theo (Milestone Target)', () {
      final target5 = streakService.getNextMilestoneTarget(5);
      expect(target5.targetDays, equals(7));
      expect(target5.remainingDays, equals(2));
      expect(target5.progressPercent, closeTo(71.4, 0.1));

      final target10 = streakService.getNextMilestoneTarget(10);
      expect(target10.targetDays, equals(14));
      expect(target10.remainingDays, equals(4));

      final target25 = streakService.getNextMilestoneTarget(25);
      expect(target25.targetDays, equals(30));
      expect(target25.remainingDays, equals(5));
    });

    test('TC-15: Khôi phục chuỗi sau thử thách bù bài học (Streak Recovery)', () {
      final brokenUser = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        currentStreak: 1, // Đã bị reset về 1
        longestStreak: 15,
        recoveredStreakCount: 0,
      );

      final recovered = streakService.recoverBrokenStreak(
        brokenUser,
        originalStreak: 15,
      );

      expect(recovered.currentStreak, equals(15));
      expect(recovered.recoveredStreakCount, equals(1));
    });

    test('TC-16: Tính toán tỷ lệ duy trì kỷ luật (Discipline Consistency Rate)', () {
      final user = UserProgressModel(
        userId: 'user_001',
        displayName: 'Nguyễn Văn Huỳnh',
        practiceDatesHistory: List.generate(15, (i) => '2026-10-${(i + 1).toString().padLeft(2, '0')}'),
      );

      final rate = streakService.calculateDisciplineConsistencyRate(user, periodDays: 30);
      expect(rate, equals(50.0));
      expect(user.consistencyRateInMonth, equals(50.0));
    });

    test('TC-17: Thông báo thử thách cuối tuần và hoàn thành mục tiêu ngày', () {
      final weekendMsg = notificationService.createWeekendChallengeNotification();
      expect(weekendMsg.contains('cuối tuần'), isTrue);

      final goalMsg = notificationService.createGoalAchievedNotification(20);
      expect(goalMsg.contains('20 phút'), isTrue);

      final latest = notificationService.notificationHistory.first;
      expect(latest.type, equals('GOAL_COMPLETED'));
      expect(latest.priority, equals(NotificationPriority.high));
    });
  });
}
