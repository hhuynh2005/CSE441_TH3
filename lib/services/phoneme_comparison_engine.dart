/// ==============================================================================
/// THUẬT TOÁN AI SO SÁNH ÂM VỊ & CHẤM ĐIỂM PHÁT ÂM (PHONEME ENGINE)
/// Phụ trách: Trần Anh Tuấn (2351170629) - Mục Checklist 4 & 5
/// ==============================================================================

import '../models/pronunciation_result_model.dart';

class PhonemeComparisonEngine {
  /// Từ điển ngữ âm mẫu (CMU Pronouncing Dictionary Subset) phục vụ đối soát
  static final Map<String, List<String>> _phoneticDictionary = {
    'cat': ['k', 'æ', 't'],
    'cats': ['k', 'æ', 't', 's'],
    'dog': ['d', 'ɒ', 'ɡ'],
    'dogs': ['d', 'ɒ', 'ɡ', 'z'],
    'sheet': ['ʃ', 'iː', 't'],
    'shit': ['ʃ', 'ɪ', 't'],
    'ship': ['ʃ', 'ɪ', 'p'],
    'sheep': ['ʃ', 'iː', 'p'],
    'think': ['θ', 'ɪ', 'ŋ', 'k'],
    'that': ['ð', 'æ', 't'],
    'water': ['w', 'ɔː', 't', 'ər'],
    'hello': ['h', 'ə', 'l', 'əʊ'],
    'world': ['w', 'ɜː', 'l', 'd'],
    'english': ['ɪ', 'ŋ', 'ɡ', 'l', 'ɪ', 'ʃ'],
  };

  /// Bảng hướng dẫn khẩu hình miệng và sửa lỗi âm vị tiếng Anh cho người Việt
  static final Map<String, String> _phonemeTips = {
    's': 'Khép nhẹ hai hàm răng, đưa đầu lưỡi lại gần chân răng trên và xì hơi nhẹ.',
    'z': 'Tương tự âm /s/ nhưng làm rung dây thanh quản ở cổ họng.',
    't': 'Chạm đầu lưỡi vào vòm họng phía sau răng trên, bật hơi dứt khoát.',
    'd': 'Tương tự âm /t/ nhưng rung thanh quản, phát âm ngắn gọn.',
    'iː': 'Cười tươi, khóe miệng kéo rộng sang hai bên, giữ hơi dài hơn âm /ɪ/.',
    'ɪ': 'Khẩu hình mở tự nhiên, phát âm dứt khoát và ngắn hơn âm /i:/.',
    'θ': 'Đặt đầu lưỡi giữa hai hàm răng trên và dưới, thổi luồng hơi nhẹ ra ngoài (không rung họng).',
    'ð': 'Vị trí lưỡi giống âm /θ/ nhưng làm rung dây thanh quản.',
    'ʃ': 'Chu môi tròn về phía trước như đang ra hiệu giữ im lặng "suỵt".',
    'ŋ': 'Nâng phần cuống lưỡi chạm vào vòm mềm, luồng hơi đi qua mũi.',
  };

  /// Trích xuất danh sách âm vị chuẩn từ từ vựng tiếng Anh (Grapheme-to-Phoneme)
  List<String> getStandardPhonemes(String word) {
    final cleanWord = word.trim().toLowerCase();
    if (_phoneticDictionary.containsKey(cleanWord)) {
      return _phoneticDictionary[cleanWord]!;
    }
    // Thuật toán tách âm vị xấp xỉ cơ bản nếu từ không có trong từ điển mẫu
    return cleanWord.split('');
  }

  /// Thuật toán Căn gióng âm vị và So sánh chi tiết (Phonetic Alignment & Scoring)
  PronunciationResult analyzePronunciation({
    required String targetWord,
    required String userRecognizedText,
    List<String>? targetPhonemesOverride,
    double pauseDurationSeconds = 0.2, // Đo độ ngắt nghỉ để tính fluency
  }) {
    final cleanTarget = targetWord.trim().toLowerCase();
    final cleanUser = userRecognizedText.trim().toLowerCase();

    final targetPhonemes = targetPhonemesOverride ?? getStandardPhonemes(cleanTarget);
    final userPhonemes = getStandardPhonemes(cleanUser);

    final phonemeDetails = <PhonemeScoreItem>[];
    int correctCount = 0;
    int missedCount = 0;
    int incorrectCount = 0;

    final targetLen = targetPhonemes.length;
    final userLen = userPhonemes.length;

    // Duyệt qua từng âm vị mục tiêu và so khớp với âm vị người dùng phát âm
    for (int i = 0; i < targetLen; i++) {
      final targetP = targetPhonemes[i];

      if (i < userLen) {
        final userP = userPhonemes[i];

        if (targetP == userP) {
          // Khớp chuẩn xác
          correctCount++;
          phonemeDetails.add(PhonemeScoreItem(
            index: i,
            targetPhoneme: targetP,
            userPhoneme: userP,
            status: PhonemeStatus.correct,
            score: 100.0,
            guidanceTip: 'Phát âm chuẩn xác.',
          ));
        } else {
          // Nhầm lẫn âm vị
          incorrectCount++;
          String errorType = 'Phát âm sai âm vị';
          if ((targetP == 'iː' && userP == 'ɪ') || (targetP == 'ɪ' && userP == 'iː')) {
            errorType = 'Nhầm cặp nguyên âm ngắn / dài';
          }

          phonemeDetails.add(PhonemeScoreItem(
            index: i,
            targetPhoneme: targetP,
            userPhoneme: userP,
            status: PhonemeStatus.incorrect,
            score: 30.0,
            errorType: errorType,
            guidanceTip: _phonemeTips[targetP] ?? 'Hãy chú ý khẩu hình miệng khi phát âm.',
          ));
        }
      } else {
        // Người dùng nuốt âm / bỏ sót âm (đặc biệt là âm cuối)
        missedCount++;
        String errorType = 'Bỏ sót âm vị';
        if (i == targetLen - 1 && ['s', 'z', 't', 'd'].contains(targetP)) {
          errorType = 'Nuốt phụ âm đuôi (Ending Sound)';
        }

        phonemeDetails.add(PhonemeScoreItem(
          index: i,
          targetPhoneme: targetP,
          userPhoneme: null,
          status: PhonemeStatus.missed,
          score: 0.0,
          errorType: errorType,
          guidanceTip: _phonemeTips[targetP] ?? 'Đừng quên bật âm cuối rõ ràng.',
        ));
      }
    }

    // 1. Tính điểm Accuracy (Độ chính xác âm vị)
    final double accuracyScore = targetLen > 0
        ? ((correctCount * 1.0 + incorrectCount * 0.3) / targetLen) * 100.0
        : 0.0;

    // 2. Tính điểm Completeness (Độ đầy đủ âm)
    final double completenessScore = targetLen > 0
        ? ((targetLen - missedCount) / targetLen) * 100.0
        : 0.0;

    // 3. Tính điểm Fluency (Độ trôi chảy, trừ điểm nếu ngắt nghỉ quá dài)
    double fluencyScore = 100.0 - (pauseDurationSeconds * 20.0);
    if (fluencyScore < 40.0) fluencyScore = 40.0;
    if (fluencyScore > 100.0) fluencyScore = 100.0;

    // 4. Tính điểm Overall Score theo trọng số chuẩn
    final double overallScore = (accuracyScore * 0.6) +
        (fluencyScore * 0.25) +
        (completenessScore * 0.15);

    // Xây dựng tóm tắt nhận xét và gợi ý bài học
    String summary = '';
    String? suggestedLesson;

    if (missedCount > 0) {
      summary = 'Bạn đang bị nuốt hoặc thiếu ${missedCount} âm vị. Chú ý bật rõ âm cuối!';
      suggestedLesson = 'Luyện tập các phụ âm đuôi (/s/, /z/, /t/, /d/)';
    } else if (incorrectCount > 0) {
      summary = 'Phát hiện ${incorrectCount} âm vị chưa chuẩn xác. Hãy xem hướng dẫn khẩu hình.';
      suggestedLesson = 'Luyện tập phân biệt nguyên âm và phụ âm tương đồng';
    } else {
      summary = 'Phát âm rất tuyệt vời! Âm sắc rõ ràng và tròn vành rõ chữ.';
    }

    return PronunciationResult(
      targetWord: cleanTarget,
      standardIpa: targetPhonemes.join(' '),
      recognizedText: cleanUser,
      recognizedIpa: userPhonemes.join(' '),
      overallScore: double.parse(overallScore.toStringAsFixed(1)),
      accuracyScore: double.parse(accuracyScore.toStringAsFixed(1)),
      fluencyScore: double.parse(fluencyScore.toStringAsFixed(1)),
      completenessScore: double.parse(completenessScore.toStringAsFixed(1)),
      phonemeDetails: phonemeDetails,
      feedbackSummary: summary,
      targetedExerciseSuggestion: suggestedLesson,
    );
  }
}
