import 'package:test/test.dart';
import '../lib/services/phoneme_comparison_engine.dart';
import '../lib/models/pronunciation_result_model.dart';

void main() {
  group('PhonemeComparisonEngine Tests (Mục 4 & 5 - Trần Anh Tuấn)', () {
    late PhonemeComparisonEngine engine;

    setUp(() {
      engine = PhonemeComparisonEngine();
    });

    test('TC-01: Phát âm chuẩn xác từ "cat" đạt điểm tối đa', () {
      final result = engine.analyzePronunciation(
        targetWord: 'cat',
        userRecognizedText: 'cat',
      );

      expect(result.overallScore, greaterThanOrEqualTo(90.0));
      expect(result.ratingTier, contains('Xuất sắc'));
      expect(result.problematicPhonemes.isEmpty, isTrue);
      expect(result.phonemeDetails.every((p) => p.status == PhonemeStatus.correct), isTrue);
    });

    test('TC-02: Phát hiện đúng lỗi nuốt phụ âm đuôi /s/ trong từ "cats"', () {
      final result = engine.analyzePronunciation(
        targetWord: 'cats',
        userRecognizedText: 'cat', // Người dùng đọc thiếu âm đuôi /s/
      );

      expect(result.overallScore, lessThan(85.0));
      expect(result.problematicPhonemes, contains('s'));
      final lastPhoneme = result.phonemeDetails.last;
      expect(lastPhoneme.status, equals(PhonemeStatus.missed));
      expect(lastPhoneme.errorType, contains('Nuốt phụ âm đuôi'));
      expect(result.targetedExerciseSuggestion, contains('/s/'));
    });

    test('TC-03: Phát hiện lỗi nhầm cặp nguyên âm ngắn / dài (/i:/ vs /ɪ/) trong "sheet"', () {
      final result = engine.analyzePronunciation(
        targetWord: 'sheet',
        userRecognizedText: 'shit', // Người dùng nhầm /i:/ thành /ɪ/
      );

      expect(result.problematicPhonemes, contains('iː'));
      final vowelPhoneme = result.phonemeDetails.firstWhere((p) => p.targetPhoneme == 'iː');
      expect(vowelPhoneme.status, equals(PhonemeStatus.incorrect));
      expect(vowelPhoneme.errorType, contains('Nhầm cặp nguyên âm ngắn / dài'));
    });

    test('TC-04: Đánh giá độ trôi chảy (Fluency) bị giảm khi ngập ngừng lâu', () {
      final normalResult = engine.analyzePronunciation(
        targetWord: 'dog',
        userRecognizedText: 'dog',
        pauseDurationSeconds: 0.1,
      );

      final hesitantResult = engine.analyzePronunciation(
        targetWord: 'dog',
        userRecognizedText: 'dog',
        pauseDurationSeconds: 1.5,
      );

      expect(hesitantResult.fluencyScore, lessThan(normalResult.fluencyScore));
      expect(hesitantResult.overallScore, lessThan(normalResult.overallScore));
    });
  });
}
