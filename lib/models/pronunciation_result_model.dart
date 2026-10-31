/// ==============================================================================
/// MÔ HÌNH DỮ LIỆU KẾT QUẢ CHẤM ĐIỂM PHÁT ÂM AI (PRONUNCIATION & PHONEME RESULT)
/// Phụ trách: Trần Anh Tuấn (2351170629) - Phân hệ AI Phoneme Scoring & Feedback
/// ==============================================================================

enum PhonemeStatus {
  correct,   // Phát âm đúng chuẩn (Màu xanh lục)
  incorrect, // Phát âm sai âm vị (Màu đỏ)
  missed,    // Nuốt âm, bỏ sót âm vị (Màu vàng cam)
  inserted   // Thừa âm không có trong từ gốc (Màu tím nhạt)
}

class PhonemeScoreItem {
  final int index;
  final String targetPhoneme;
  final String? userPhoneme;
  final PhonemeStatus status;
  final double score; // 0.0 - 100.0
  final String? errorType; // vd: 'Nuốt phụ âm đuôi', 'Nhầm nguyên âm dài'
  final String? guidanceTip; // Hướng dẫn vị trí đặt lưỡi / mở khẩu hình miệng

  PhonemeScoreItem({
    required this.index,
    required this.targetPhoneme,
    this.userPhoneme,
    required this.status,
    required this.score,
    this.errorType,
    this.guidanceTip,
  });

  Map<String, dynamic> toMap() {
    return {
      'phoneme_index': index,
      'target_phoneme': targetPhoneme,
      'user_phoneme': userPhoneme,
      'status': status.name.toUpperCase(),
      'score': score,
      'error_type': errorType,
      'guidance_tip': guidanceTip,
    };
  }

  factory PhonemeScoreItem.fromMap(Map<String, dynamic> map) {
    return PhonemeScoreItem(
      index: map['phoneme_index'] ?? 0,
      targetPhoneme: map['target_phoneme'] ?? '',
      userPhoneme: map['user_phoneme'],
      status: PhonemeStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == (map['status'] ?? 'CORRECT'),
        orElse: () => PhonemeStatus.correct,
      ),
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      errorType: map['error_type'],
      guidanceTip: map['guidance_tip'],
    );
  }
}

class PronunciationResult {
  final String targetWord;
  final String standardIpa;
  final String recognizedText;
  final String recognizedIpa;
  final double overallScore;     // Điểm tổng quát (0 - 100)
  final double accuracyScore;    // Độ chuẩn xác từng âm vị (0 - 100)
  final double fluencyScore;     // Độ trôi chảy & ngắt nghỉ (0 - 100)
  final double completenessScore;// Độ đầy đủ âm tiết (0 - 100)
  final List<PhonemeScoreItem> phonemeDetails;
  final String feedbackSummary;
  final String? targetedExerciseSuggestion;

  PronunciationResult({
    required this.targetWord,
    required this.standardIpa,
    required this.recognizedText,
    required this.recognizedIpa,
    required this.overallScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.phonemeDetails,
    required this.feedbackSummary,
    this.targetedExerciseSuggestion,
  });

  /// Đánh giá xếp loại: Xuất sắc, Tốt, Cần cải thiện
  String get ratingTier {
    if (overallScore >= 85) return 'Xuất sắc ⭐⭐⭐';
    if (overallScore >= 70) return 'Tốt ⭐⭐';
    if (overallScore >= 50) return 'Cần luyện tập thêm ⭐';
    return 'Chưa đạt ⚠️';
  }

  /// Danh sách các âm vị bị đọc sai cần tập trung khắc phục
  List<String> get problematicPhonemes => phonemeDetails
      .where((p) => p.status == PhonemeStatus.incorrect || p.status == PhonemeStatus.missed)
      .map((p) => p.targetPhoneme)
      .toSet()
      .toList();

  Map<String, dynamic> toMap() {
    return {
      'target_word': targetWord,
      'standard_ipa': standardIpa,
      'recognized_text': recognizedText,
      'recognized_ipa': recognizedIpa,
      'overall_score': overallScore,
      'accuracy_score': accuracyScore,
      'fluency_score': fluencyScore,
      'completeness_score': completenessScore,
      'feedback_summary': feedbackSummary,
      'suggested_exercise': targetedExerciseSuggestion,
      'phonemes': phonemeDetails.map((p) => p.toMap()).toList(),
    };
  }
}
