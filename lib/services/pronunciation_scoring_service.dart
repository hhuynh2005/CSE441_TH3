/// ==============================================================================
/// SERVICE CHẤM ĐIỂM PHÁT ÂM (PRONUNCIATION SCORING SERVICE)
/// Phụ trách: Trần Anh Tuấn (2351170629) - Mục Checklist 4
/// ==============================================================================
///
/// Tách logic chấm điểm 3 tiêu chí ra khỏi [PhonemeComparisonEngine] để tái sử dụng.
/// CÔNG THỨC GIỮ NGUYÊN 100% như engine hiện tại của repo:
///   • Accuracy     = (correct + incorrect × 0.3) / targetLen × 100
///   • Completeness = (targetLen − missed) / targetLen × 100
///   • Fluency      = clamp(100 − pause × 20, 40, 100)
///   • Overall      = 0.6·Accuracy + 0.25·Fluency + 0.15·Completeness
///
/// File pure Dart (không phụ thuộc Flutter) để dễ unit test.
/// Tương thích với model hiện tại của repo (PhonemeScoreItem/PhonemeStatus).

import '../models/pronunciation_result_model.dart';

/// Bộ điểm 3 tiêu chí + điểm tổng hợp (thang 0–100).
class PronunciationScores {
  final double accuracy;
  final double fluency;
  final double completeness;
  final double overall;

  const PronunciationScores({
    required this.accuracy,
    required this.fluency,
    required this.completeness,
    required this.overall,
  });
}

class PronunciationScoringService {
  const PronunciationScoringService();

  /// Trọng số điểm tổng hợp (khớp engine hiện tại của repo).
  static const double weightAccuracy = 0.6;
  static const double weightFluency = 0.25;
  static const double weightCompleteness = 0.15;

  /// Mỗi giây ngập ngừng trừ 20 điểm Fluency, chặn trong [40, 100].
  static const double pausePenaltyPerSecond = 20.0;
  static const double minFluency = 40.0;
  static const double maxFluency = 100.0;

  /// Tính điểm từ chi tiết căn gióng ([PhonemeScoreItem]) của engine.
  ///
  /// [details] danh sách âm vị đã căn gióng, [targetLen] tổng số âm chuẩn,
  /// [pauseDurationSeconds] thời gian ngập ngừng (giây).
  PronunciationScores calculate({
    required List<PhonemeScoreItem> details,
    required int targetLen,
    double pauseDurationSeconds = 0.2,
  }) {
    var correct = 0;
    var incorrect = 0;
    var missed = 0;

    for (final d in details) {
      switch (d.status) {
        case PhonemeStatus.correct:
          correct++;
          break;
        case PhonemeStatus.incorrect:
          incorrect++;
          break;
        case PhonemeStatus.missed:
          missed++;
          break;
        case PhonemeStatus.inserted:
          // Âm thừa không thuộc dãy chuẩn nên không tính vào 3 tiêu chí
          // (đã được phản ánh qua widget highlight màu tím).
          break;
      }
    }

    final accuracy =
        targetLen > 0 ? ((correct + incorrect * 0.3) / targetLen) * 100.0 : 0.0;
    final completeness =
        targetLen > 0 ? ((targetLen - missed) / targetLen) * 100.0 : 0.0;
    final fluency = (maxFluency - pauseDurationSeconds * pausePenaltyPerSecond)
        .clamp(minFluency, maxFluency);
    final overall = accuracy * weightAccuracy +
        fluency * weightFluency +
        completeness * weightCompleteness;

    // Làm tròn 1 chữ số thập phân như engine hiện tại.
    double r(double v) => double.parse(v.toStringAsFixed(1));

    return PronunciationScores(
      accuracy: r(accuracy),
      fluency: r(fluency),
      completeness: r(completeness),
      overall: r(overall),
    );
  }

  /// Xếp hạng, khớp với getter [PronunciationResult.ratingTier] của repo.
  static String tierFor(double overall) {
    if (overall >= 85) return 'Xuất sắc ⭐⭐⭐';
    if (overall >= 70) return 'Tốt ⭐⭐';
    if (overall >= 50) return 'Cần luyện tập thêm ⭐';
    return 'Chưa đạt ⚠️';
  }
}
