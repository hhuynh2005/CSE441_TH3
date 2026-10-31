import 'package:test/test.dart';
import '../lib/services/streak_service.dart';
import '../lib/models/user_progress_model.dart';

void main() {
  group('StreakService Tests (Mục 2 & 6 - Lê Anh Tuấn)', () {
    late StreakService streakService;

    setUp(() {
      streakService = StreakService();
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
  });
}
