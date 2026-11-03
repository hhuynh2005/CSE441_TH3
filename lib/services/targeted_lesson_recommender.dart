/// ==============================================================================
/// RECOMMENTDER GỢI Ý BÀI TẬP CÁ NHÂN HÓA (TARGETED LESSON RECOMMENDER)
/// Phụ trách: Trần Anh Tuấn (2351170629) - Mục Checklist 5
/// ==============================================================================
///
/// Từ danh sách âm vị yếu ([PronunciationResult.problematicPhonemes]),
/// đề xuất bài tập cho từng âm: mẹo khẩu hình miệng + các từ luyện tập
/// chứa âm đó.
///
/// File pure Dart (không phụ thuộc Flutter) để dễ unit test.
/// Tương thích với model hiện tại của repo (PhonemeScoreItem/PronunciationResult).

import '../models/pronunciation_result_model.dart';

/// Một từ luyện tập kèm phiên âm hiển thị.
class PracticeWord {
  final String word;
  final String ipaDisplay; // ví dụ '/θɪŋk/'

  const PracticeWord(this.word, this.ipaDisplay);
}

/// Gói bài tập cho một âm vị yếu.
class TargetedExercise {
  /// Âm vị yếu, ví dụ 'θ'.
  final String phoneme;

  /// Dạng hiển thị, ví dụ '/θ/'.
  String get ipaDisplay => '/$phoneme/';

  /// Mẹo khẩu hình miệng bằng tiếng Việt.
  final String mouthTip;

  /// Các từ nên luyện thêm.
  final List<PracticeWord> words;

  const TargetedExercise({
    required this.phoneme,
    required this.mouthTip,
    required this.words,
  });
}

class TargetedLessonRecommender {
  // ---------------------------------------------------------------------------
  // MẸO KHẨU HÌNH MIỆNG cho từng âm vị (tiếng Việt).
  // ---------------------------------------------------------------------------
  static const Map<String, String> phonemeTips = {
    'θ':
        'Đầu lưỡi đặt giữa hai hàm răng, đẩy hơi ra nhẹ, không rung dây thanh.',
    'ð': 'Vị trí lưỡi như /θ/ nhưng rung dây thanh.',
    'ʃ': 'Môi tròn, đầu lưỡi cong lên vòm miệng, hơi xì dài.',
    'tʃ': 'Bật /t/ rồi lướt ngay sang /ʃ/ trong một hơi.',
    'dʒ': 'Bật /d/ rồi lướt ngay sang /ʒ/ trong một hơi.',
    'ŋ': 'Âm mũi: lưỡi chạm vòm họng mềm, hơi thoát qua mũi, không bật /g/.',
    'iː': 'Miệng cười rộng, kéo dài âm.',
    'ɪ': 'Miệng hơi mở, âm ngắn và gọn.',
    'uː': 'Môi tròn chặt, kéo dài âm.',
    'ʊ': 'Môi tròn nhẹ, âm ngắn.',
    'æ': 'Miệng mở rộng, lưỡi hạ thấp.',
    'e': 'Miệng mở vừa, lưỡi nâng nhẹ.',
    'ə': 'Âm "ơ" nhẹ, thả lỏng toàn bộ cơ miệng.',
    'ɜː': 'Âm "ơ" dài, môi hơi tròn.',
    'ʌ': 'Âm "ă" ngắn, dứt khoát.',
    'ɑː': 'Miệng mở to, kéo dài âm.',
    'ɒ': 'Miệng mở tròn.',
    'ɔː': 'Môi tròn, kéo dài âm.',
    's': 'Xì hơi qua kẽ răng, không rung dây thanh — nhớ bật rõ âm đuôi.',
    'z': 'Như /s/ nhưng rung dây thanh.',
    't': 'Bật hơi dứt khoát ở đầu lưỡi — đừng nuốt âm đuôi.',
    'd': 'Như /t/ nhưng rung dây thanh.',
    'l': 'Đầu lưỡi chạm nướu răng trên.',
    'r': 'Đầu lưỡi cong lên nhưng không chạm vòm miệng.',
    'w': 'Môi tròn như huýt sáo rồi mở ra.',
    'j': 'Lưỡi nâng gần vòm miệng như âm "d" nhẹ.',
    'eɪ': 'Lướt từ /e/ sang /ɪ/ trong một hơi.',
    'aɪ': 'Lướt từ /ɑ/ sang /ɪ/ trong một hơi.',
    'oʊ': 'Lướt từ /ə/ sang /ʊ/ trong một hơi.',
    'aʊ': 'Lướt từ /a/ sang /ʊ/ trong một hơi.',
    'ɔɪ': 'Lướt từ /ɔ/ sang /ɪ/ trong một hơi.',
    'f': 'Răng trên chạm môi dưới, xì hơi.',
    'v': 'Như /f/ nhưng rung dây thanh.',
    'h': 'Đẩy hơi từ cổ họng.',
    'p': 'Mím môi rồi bật hơi mạnh.',
    'b': 'Như /p/ nhưng rung dây thanh.',
    'k': 'Bật hơi ở cuống lưỡi.',
    'ɡ': 'Như /k/ nhưng rung dây thanh.',
    'm': 'Mím môi, hơi thoát qua mũi.',
    'n': 'Đầu lưỡi chạm nướu răng trên, hơi thoát qua mũi.',
  };

  // ---------------------------------------------------------------------------
  // TỪ LUYỆN TẬP theo từng âm vị.
  // ---------------------------------------------------------------------------
  static const Map<String, List<PracticeWord>> phonemePracticeWords = {
    'θ': [
      PracticeWord('think', '/θɪŋk/'),
      PracticeWord('three', '/θriː/'),
      PracticeWord('mouth', '/maʊθ/'),
    ],
    'ð': [
      PracticeWord('this', '/ðɪs/'),
      PracticeWord('that', '/ðæt/'),
      PracticeWord('mother', '/mʌðə/'),
    ],
    'ʃ': [
      PracticeWord('ship', '/ʃɪp/'),
      PracticeWord('fish', '/fɪʃ/'),
      PracticeWord('wash', '/wɒʃ/'),
    ],
    'tʃ': [
      PracticeWord('chair', '/tʃeə/'),
      PracticeWord('watch', '/wɒtʃ/'),
      PracticeWord('cheese', '/tʃiːz/'),
    ],
    'dʒ': [
      PracticeWord('job', '/dʒɒb/'),
      PracticeWord('page', '/peɪdʒ/'),
      PracticeWord('enjoy', '/endʒɔɪ/'),
    ],
    'ŋ': [
      PracticeWord('sing', '/sɪŋ/'),
      PracticeWord('long', '/lɒŋ/'),
      PracticeWord('morning', '/mɔːnɪŋ/'),
    ],
    'iː': [
      PracticeWord('sheet', '/ʃiːt/'),
      PracticeWord('sleep', '/sliːp/'),
      PracticeWord('speak', '/spiːk/'),
    ],
    'ɪ': [
      PracticeWord('ship', '/ʃɪp/'),
      PracticeWord('fish', '/fɪʃ/'),
      PracticeWord('list', '/lɪst/'),
    ],
    'æ': [
      PracticeWord('cat', '/kæt/'),
      PracticeWord('apple', '/æpəl/'),
      PracticeWord('practice', '/præktɪs/'),
    ],
    's': [
      PracticeWord('cats', '/kæts/'),
      PracticeWord('test', '/test/'),
      PracticeWord('best', '/best/'),
    ],
    'z': [
      PracticeWord('zebra', '/zebrə/'),
      PracticeWord('zoo', '/zuː/'),
      PracticeWord('friends', '/frendz/'),
    ],
    't': [
      PracticeWord('test', '/test/'),
      PracticeWord('night', '/naɪt/'),
      PracticeWord('wanted', '/wɒntɪd/'),
    ],
    'd': [
      PracticeWord('dog', '/dɒɡ/'),
      PracticeWord('played', '/pleɪd/'),
      PracticeWord('red', '/red/'),
    ],
    'eɪ': [
      PracticeWord('name', '/neɪm/'),
      PracticeWord('day', '/deɪ/'),
      PracticeWord('train', '/treɪn/'),
    ],
    'aɪ': [
      PracticeWord('time', '/taɪm/'),
      PracticeWord('my', '/maɪ/'),
      PracticeWord('night', '/naɪt/'),
    ],
    'oʊ': [
      PracticeWord('go', '/ɡoʊ/'),
      PracticeWord('phone', '/foʊn/'),
      PracticeWord('window', '/wɪndoʊ/'),
    ],
    'aʊ': [
      PracticeWord('house', '/haʊs/'),
      PracticeWord('now', '/naʊ/'),
      PracticeWord('mouth', '/maʊθ/'),
    ],
    'ɜː': [
      PracticeWord('bird', '/bɜːd/'),
      PracticeWord('work', '/wɜːk/'),
      PracticeWord('learn', '/lɜːn/'),
    ],
    'ʌ': [
      PracticeWord('cup', '/kʌp/'),
      PracticeWord('love', '/lʌv/'),
      PracticeWord('mother', '/mʌðə/'),
    ],
    'ɒ': [
      PracticeWord('dog', '/dɒɡ/'),
      PracticeWord('hot', '/hɒt/'),
      PracticeWord('box', '/bɒks/'),
    ],
    'ɔː': [
      PracticeWord('all', '/ɔːl/'),
      PracticeWord('call', '/kɔːl/'),
      PracticeWord('water', '/wɔːtə/'),
    ],
    'ə': [
      PracticeWord('mother', '/mʌðə/'),
      PracticeWord('banana', '/bənɑːnə/'),
      PracticeWord('teacher', '/tiːtʃə/'),
    ],
    'e': [
      PracticeWord('pen', '/pen/'),
      PracticeWord('bed', '/bed/'),
      PracticeWord('test', '/test/'),
    ],
    'uː': [
      PracticeWord('food', '/fuːd/'),
      PracticeWord('school', '/skuːl/'),
      PracticeWord('two', '/tuː/'),
    ],
    'ʊ': [
      PracticeWord('book', '/bʊk/'),
      PracticeWord('look', '/lʊk/'),
      PracticeWord('pure', '/pjʊə/'),
    ],
  };

  /// Đề xuất bài tập cho từng âm vị yếu (đã khử trùng, giữ thứ tự).
  List<TargetedExercise> recommend(
    List<String> weakPhonemes, {
    int maxWordsPerPhoneme = 3,
  }) {
    final seen = <String>{};
    final result = <TargetedExercise>[];
    for (final phoneme in weakPhonemes) {
      if (!seen.add(phoneme)) continue; // bỏ trùng
      final tip = phonemeTips[phoneme] ??
          'Luyện đọc chậm, nghe mẫu chuẩn và bắt chước khẩu hình.';
      final words = (phonemePracticeWords[phoneme] ?? const <PracticeWord>[])
          .take(maxWordsPerPhoneme)
          .toList();
      result
          .add(TargetedExercise(phoneme: phoneme, mouthTip: tip, words: words));
    }
    return result;
  }

  /// Tiện ích: đề xuất thẳng từ [PronunciationResult] của engine.
  /// Dùng getter [PronunciationResult.problematicPhonemes] có sẵn của repo.
  List<TargetedExercise> recommendFromResult(
    PronunciationResult result, {
    int maxWordsPerPhoneme = 3,
  }) {
    return recommend(result.problematicPhonemes,
        maxWordsPerPhoneme: maxWordsPerPhoneme);
  }

  /// Dựng chuỗi gợi ý ngắn gọn (dạng text) từ danh sách âm yếu.
  static String buildSuggestion(List<String> weakPhonemes) {
    if (weakPhonemes.isEmpty) {
      return 'Phát âm tốt! Hãy duy trì luyện tập đều đặn mỗi ngày.';
    }
    final listed = weakPhonemes.map((p) => '/$p/').join(', ');
    final buffer = StringBuffer('Hãy luyện thêm các âm còn yếu: $listed.');
    for (final p in weakPhonemes) {
      final tip = phonemeTips[p];
      if (tip != null) buffer.write('\n- /$p/: $tip');
    }
    return buffer.toString();
  }
}
