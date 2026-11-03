/// ==============================================================================
/// THUẬT TOÁN AI SO SÁNH ÂM VỊ & CHẤM ĐIỂM PHÁT ÂM (PHONEME ENGINE)
/// Phụ trách: Trần Anh Tuấn (2351170629) - Mục Checklist 4 & 5
/// ==============================================================================

import '../models/pronunciation_result_model.dart';

class PhonemeComparisonEngine {
  /// Từ điển ngữ âm mẫu (CMU Pronouncing Dictionary Subset) phục vụ đối soát
  static final Map<String, List<String>> _phoneticDictionary = {
    // 🔤 Âm vị dễ nhầm (Confusing phonemes)
    'cat': ['k', 'æ', 't'],
    'cats': ['k', 'æ', 't', 's'],
    'cut': ['k', 'ʌ', 't'],
    'dog': ['d', 'ɒ', 'ɡ'],
    'dogs': ['d', 'ɒ', 'ɡ', 'z'],
    'sheet': ['ʃ', 'iː', 't'],
    'shit': ['ʃ', 'ɪ', 't'],
    'ship': ['ʃ', 'ɪ', 'p'],
    'sheep': ['ʃ', 'iː', 'p'],
    'seat': ['s', 'iː', 't'],
    'sit': ['s', 'ɪ', 't'],
    'think': ['θ', 'ɪ', 'ŋ', 'k'],
    'that': ['ð', 'æ', 't'],
    'this': ['ð', 'ɪ', 's'],
    'water': ['w', 'ɔː', 't', 'ər'],
    'vision': ['v', 'ɪ', 'ʒ', 'n'],

    // 💼 Giao tiếp công sở (Workplace & Business)
    'schedule': ['s', 'k', 'e', 'dʒ', 'uː', 'l'],
    'colleague': ['k', 'ɒ', 'l', 'iː', 'ɡ'],
    'presentation': ['p', 'r', 'e', 'z', 'n', 't', 'eɪ', 'ʃ', 'n'],
    'negotiation': ['n', 'ɪ', 'ɡ', 'əʊ', 'ʃ', 'i', 'eɪ', 'ʃ', 'n'],
    'deadline': ['d', 'e', 'd', 'l', 'aɪ', 'n'],
    'developer': ['d', 'ɪ', 'v', 'e', 'l', 'ə', 'p', 'ər'],
    'management': ['m', 'æ', 'n', 'ɪ', 'dʒ', 'm', 'ə', 'n', 't'],
    'experience': ['ɪ', 'k', 's', 'p', 'ɪə', 'r', 'i', 'ə', 'n', 's'],

    // ✈️ Du lịch & Khách sạn (Travel & Hospitality)
    'passport': ['p', 'ɑː', 's', 'p', 'ɔː', 't'],
    'reservation': ['r', 'e', 'z', 'ə', 'v', 'eɪ', 'ʃ', 'n'],
    'itinerary': ['aɪ', 't', 'ɪ', 'n', 'ə', 'r', 'ə', 'r', 'i'],
    'destination': ['d', 'e', 's', 't', 'ɪ', 'n', 'eɪ', 'ʃ', 'n'],
    'departure': ['d', 'ɪ', 'p', 'ɑː', 'tʃ', 'ər'],
    'luggage': ['l', 'ʌ', 'ɡ', 'ɪ', 'dʒ'],
    'boarding': ['b', 'ɔː', 'd', 'ɪ', 'ŋ'],
    'restaurant': ['r', 'e', 's', 't', 'r', 'ɒ', 'n', 't'],

    // 💻 Công nghệ & Kỹ thuật (Technology & IT)
    'artificial': ['ɑː', 't', 'ɪ', 'f', 'ɪ', 'ʃ', 'l'],
    'intelligence': ['ɪ', 'n', 't', 'e', 'l', 'ɪ', 'dʒ', 'ə', 'n', 's'],
    'algorithm': ['æ', 'l', 'ɡ', 'ə', 'r', 'ɪ', 'ð', 'ə', 'm'],
    'database': ['d', 'eɪ', 't', 'ə', 'b', 'eɪ', 's'],
    'architecture': ['ɑː', 'k', 'ɪ', 't', 'e', 'k', 'tʃ', 'ər'],
    'cybersecurity': ['s', 'aɪ', 'b', 'ə', 's', 'ɪ', 'k', 'j', 'ʊə', 'r', 'ə', 't', 'i'],
    'cloud': ['k', 'l', 'aʊ', 'd'],
    'application': ['æ', 'p', 'l', 'ɪ', 'k', 'eɪ', 'ʃ', 'n'],

    // Từ vựng nền tảng khác
    'hello': ['h', 'ə', 'l', 'əʊ'],
    'world': ['w', 'ɜː', 'l', 'd'],
    'english': ['ɪ', 'ŋ', 'ɡ', 'l', 'ɪ', 'ʃ'],
    'practice': ['p', 'r', 'æ', 'k', 't', 'ɪ', 's'],
    'makes': ['m', 'eɪ', 'k', 's'],
    'perfect': ['p', 'ɜː', 'f', 'ɪ', 'k', 't'],
  };

  /// Bảng hướng dẫn khẩu hình miệng và sửa lỗi âm vị tiếng Anh cho người Việt
  static final Map<String, String> _phonemeTips = {
    's': 'Khép nhẹ hai hàm răng, đưa đầu lưỡi lại gần chân răng trên và xì hơi nhẹ.',
    'z': 'Tương tự âm /s/ nhưng làm rung dây thanh quản ở cổ họng.',
    't': 'Chạm đầu lưỡi vào vòm họng phía sau răng trên, bật hơi dứt khoát.',
    'd': 'Tương tự âm /t/ nhưng rung thanh quản, phát âm ngắn gọn.',
    'iː': 'Cười tươi, khóe miệng kéo rộng sang hai bên, giữ hơi dài hơn âm /ɪ/.',
    'ɪ': 'Khẩu hình mở tự nhiên, phát âm dứt khoát và ngắn hơn âm /i:/.',
    'æ': 'Hạ cằm xuống sâu, mở rộng miệng theo chiều dọc và ngang để phát âm /æ/.',
    'ʌ': 'Mở miệng vừa phải, lưỡi ở vị trí trung tâm, phát âm dứt khoát như "á".',
    'θ': 'Đặt đầu lưỡi giữa hai hàm răng trên và dưới, thổi luồng hơi nhẹ ra ngoài (không rung họng).',
    'ð': 'Vị trí lưỡi giống âm /θ/ nhưng làm rung dây thanh quản.',
    'ʃ': 'Chu môi tròn về phía trước như đang ra hiệu giữ im lặng "suỵt".',
    'ʒ': 'Khẩu hình giống /ʃ/ nhưng rung dây thanh quản tương tự chữ "gi" trong tiếng Pháp.',
    'tʃ': 'Bắt đầu từ âm /t/ rồi chu môi trượt sang /ʃ/, bật hơi mạnh (như "ch").',
    'dʒ': 'Khẩu hình giống /tʃ/ nhưng làm rung dây thanh quản mạnh mẽ.',
    'ŋ': 'Nâng phần cuống lưỡi chạm vào vòm mềm, luồng hơi đi qua mũi.',
    'eɪ': 'Bắt đầu từ /e/ rồi trượt nhanh nhẹ nhàng sang /ɪ/.',
    'aɪ': 'Mở miệng âm /a/ rồi thu nhỏ khóe miệng trượt sang /ɪ/.',
    'aʊ': 'Mở miệng âm /a/ rồi chu môi trượt nhanh sang /ʊ/.',
  };

  /// Trích xuất danh sách âm vị chuẩn từ từ vựng hoặc câu tiếng Anh (G2P)
  List<String> getStandardPhonemes(String word) {
    final clean = word.trim().toLowerCase().replaceAll(RegExp(r'[.,!?;:]'), '');
    if (clean.isEmpty) return [];

    if (clean.contains(' ')) {
      final subwords = clean.split(RegExp(r'\s+'));
      final result = <String>[];
      for (final sw in subwords) {
        result.addAll(getStandardPhonemes(sw));
      }
      return result;
    }

    if (_phoneticDictionary.containsKey(clean)) {
      return _phoneticDictionary[clean]!;
    }
    // Thuật toán tách âm vị xấp xỉ cơ bản nếu từ chưa có trong từ điển mẫu
    return clean.split('');
  }

  /// Thuật toán Căn gióng âm vị và So sánh chi tiết (Phonetic Alignment & Scoring)
  PronunciationResult analyzePronunciation({
    required String targetWord,
    required String userRecognizedText,
    List<String>? targetPhonemesOverride,
    double pauseDurationSeconds = 0.2, // Đo độ ngắt nghỉ để tính fluency
  }) {
    final cleanTarget = targetWord.trim().toLowerCase().replaceAll(RegExp(r'[.,!?;:]'), '');
    final cleanUser = userRecognizedText.trim().toLowerCase().replaceAll(RegExp(r'[.,!?;:]'), '');

    final targetPhonemes = targetPhonemesOverride ?? getStandardPhonemes(cleanTarget);
    final userPhonemes = getStandardPhonemes(cleanUser);

    // Trường hợp 1: Người dùng không nói gì (im lặng hoặc mic không bắt được âm thanh)
    if (cleanUser.isEmpty) {
      final phonemeDetails = targetPhonemes.asMap().entries.map((entry) {
        return PhonemeScoreItem(
          index: entry.key,
          targetPhoneme: entry.value,
          userPhoneme: null,
          status: PhonemeStatus.missed,
          score: 0.0,
          errorType: 'Không phát hiện âm thanh',
          guidanceTip: _phonemeTips[entry.value] ?? 'Hãy mở miệng và nói to rõ ràng vào Micro.',
        );
      }).toList();

      return PronunciationResult(
        targetWord: cleanTarget,
        standardIpa: targetPhonemes.join(' '),
        recognizedText: '',
        recognizedIpa: '',
        overallScore: 0.0,
        accuracyScore: 0.0,
        fluencyScore: 0.0,
        completenessScore: 0.0,
        phonemeDetails: phonemeDetails,
        feedbackSummary: '⚠️ Không phát hiện giọng nói hoặc âm lượng quá nhỏ. Hãy nói to, rõ ràng vào Micro!',
        targetedExerciseSuggestion: 'Kiểm tra quyền truy cập Micro và luyện đọc to rõ từng từ vựng.',
      );
    }

    // Trường hợp 2: Có nhận diện được giọng nói
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
          } else if ((targetP == 'æ' && userP == 'ʌ') || (targetP == 'ʌ' && userP == 'æ')) {
            errorType = 'Nhầm nguyên âm /æ/ và /ʌ/';
          } else if ((targetP == 's' && userP == 'ʃ') || (targetP == 'ʃ' && userP == 's')) {
            errorType = 'Nhầm lẫn âm xì /s/ và âm chu môi /ʃ/';
          } else if ((targetP == 'θ' && userP == 't') || (targetP == 'θ' && userP == 's')) {
            errorType = 'Nhầm âm /θ/ với /t/ hoặc /s/';
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
      summary = 'Bạn đang bị nuốt hoặc thiếu $missedCount âm vị. Chú ý bật rõ âm cuối!';
      suggestedLesson = 'Luyện tập các phụ âm đuôi (/s/, /z/, /t/, /d/)';
    } else if (incorrectCount > 0) {
      summary = 'Phát hiện $incorrectCount âm vị chưa chuẩn xác. Hãy xem hướng dẫn khẩu hình.';
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
