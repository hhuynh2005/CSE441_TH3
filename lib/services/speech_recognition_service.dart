/// ==============================================================================
/// DỊCH VỤ NHẬN DẠNG GIỌNG NÓI & PHÁT ÂM MẪU BẢN XỨ (SPEECH RECOGNITION SERVICE)
/// Phụ trách: NGUYỄN TRUNG KIÊN (2251172394) - Checklist 3 & Sprint 2
/// ==============================================================================

import 'dart:async';
import 'dart:math';
import 'audio_recording_manager.dart';

/// Mốc thời gian của từng âm vị được nhận dạng trong luồng âm thanh
class SpeechPhonemeTimestamp {
  final String phoneme;
  final int startOffsetMs;
  final int endOffsetMs;
  final double confidence;

  const SpeechPhonemeTimestamp({
    required this.phoneme,
    required this.startOffsetMs,
    required this.endOffsetMs,
    this.confidence = 0.95,
  });

  Map<String, dynamic> toMap() {
    return {
      'phoneme': phoneme,
      'start_ms': startOffsetMs,
      'end_ms': endOffsetMs,
      'confidence': confidence,
    };
  }
}

/// Mốc thời gian chi tiết của từng từ vựng kèm danh sách âm vị
class SpeechWordTimestamp {
  final String word;
  final int startOffsetMs;
  final int endOffsetMs;
  final double confidence;
  final List<SpeechPhonemeTimestamp> phonemeTimestamps;

  const SpeechWordTimestamp({
    required this.word,
    required this.startOffsetMs,
    required this.endOffsetMs,
    required this.confidence,
    this.phonemeTimestamps = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'start_ms': startOffsetMs,
      'end_ms': endOffsetMs,
      'confidence': confidence,
      'phonemes': phonemeTimestamps.map((p) => p.toMap()).toList(),
    };
  }
}

/// Kết quả nhận diện từ mô hình Speech-to-Text (STT)
class SpeechRecognitionResult {
  final String recognizedText;
  final double confidence; // Độ tin cậy (0.0 - 1.0)
  final String audioFilePath;
  final Duration recordingDuration;
  final List<SpeechWordTimestamp> wordTimestamps;
  final String engineType; // 'GoogleCloudSTT', 'WhisperAI', 'NativeSpeechRecognizer'
  final bool isSilent;
  final bool isNoisy;

  SpeechRecognitionResult({
    required this.recognizedText,
    required this.confidence,
    required this.audioFilePath,
    required this.recordingDuration,
    this.wordTimestamps = const [],
    this.engineType = 'WhisperAI',
    this.isSilent = false,
    this.isNoisy = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'recognized_text': recognizedText,
      'confidence': confidence,
      'audio_file_path': audioFilePath,
      'duration_ms': recordingDuration.inMilliseconds,
      'engine_type': engineType,
      'is_silent': isSilent,
      'is_noisy': isNoisy,
      'word_timestamps': wordTimestamps.map((w) => w.toMap()).toList(),
    };
  }
}

/// Thông tin bài mẫu phát âm người bản xứ (Native Speaker Audio Sample)
class NativeSpeakerSample {
  final String word;
  final String ipa;
  final String accent; // 'US' (Mỹ) hoặc 'UK' (Anh)
  final String audioUrl;
  final String speakerGender; // 'Male' hoặc 'Female'
  final Duration sampleDuration;

  const NativeSpeakerSample({
    required this.word,
    required this.ipa,
    required this.accent,
    required this.audioUrl,
    required this.speakerGender,
    required this.sampleDuration,
  });
}

/// Dịch vụ Nhận dạng Giọng nói và Tương tác Âm thanh chuẩn
class SpeechRecognitionService {
  final AudioRecordingManager _recordingManager;

  bool _isRecording = false;
  DateTime? _recordingStartTime;
  bool _isPlayingNativeSample = false;

  final StreamController<bool> _nativePlaybackController =
      StreamController<bool>.broadcast();

  SpeechRecognitionService({
    AudioRecordingManager? recordingManager,
  }) : _recordingManager = recordingManager ?? AudioRecordingManager();

  bool get isRecording => _isRecording;
  bool get isPlayingNativeSample => _isPlayingNativeSample;
  Stream<bool> get nativePlaybackStream => _nativePlaybackController.stream;
  AudioRecordingManager get recordingManager => _recordingManager;

  /// Kho dữ liệu phát âm mẫu người bản xứ chuẩn hóa (Native Audio Repository)
  static final Map<String, Map<String, NativeSpeakerSample>> _nativeSamples = {
    'cat': {
      'US': const NativeSpeakerSample(
        word: 'cat',
        ipa: '/kæt/',
        accent: 'US',
        audioUrl: 'https://assets.speakup.ai/audio/samples/us_cat.mp3',
        speakerGender: 'Female',
        sampleDuration: Duration(milliseconds: 750),
      ),
      'UK': const NativeSpeakerSample(
        word: 'cat',
        ipa: '/kæt/',
        accent: 'UK',
        audioUrl: 'https://assets.speakup.ai/audio/samples/uk_cat.mp3',
        speakerGender: 'Male',
        sampleDuration: Duration(milliseconds: 720),
      ),
    },
    'cats': {
      'US': const NativeSpeakerSample(
        word: 'cats',
        ipa: '/kæts/',
        accent: 'US',
        audioUrl: 'https://assets.speakup.ai/audio/samples/us_cats.mp3',
        speakerGender: 'Female',
        sampleDuration: Duration(milliseconds: 820),
      ),
      'UK': const NativeSpeakerSample(
        word: 'cats',
        ipa: '/kæts/',
        accent: 'UK',
        audioUrl: 'https://assets.speakup.ai/audio/samples/uk_cats.mp3',
        speakerGender: 'Male',
        sampleDuration: Duration(milliseconds: 800),
      ),
    },
    'think': {
      'US': const NativeSpeakerSample(
        word: 'think',
        ipa: '/θɪŋk/',
        accent: 'US',
        audioUrl: 'https://assets.speakup.ai/audio/samples/us_think.mp3',
        speakerGender: 'Female',
        sampleDuration: Duration(milliseconds: 880),
      ),
      'UK': const NativeSpeakerSample(
        word: 'think',
        ipa: '/θɪŋk/',
        accent: 'UK',
        audioUrl: 'https://assets.speakup.ai/audio/samples/uk_think.mp3',
        speakerGender: 'Male',
        sampleDuration: Duration(milliseconds: 860),
      ),
    },
    'water': {
      'US': const NativeSpeakerSample(
        word: 'water',
        ipa: '/ˈwɔːtər/',
        accent: 'US',
        audioUrl: 'https://assets.speakup.ai/audio/samples/us_water.mp3',
        speakerGender: 'Male',
        sampleDuration: Duration(milliseconds: 920),
      ),
      'UK': const NativeSpeakerSample(
        word: 'water',
        ipa: '/ˈwɔːtə/',
        accent: 'UK',
        audioUrl: 'https://assets.speakup.ai/audio/samples/uk_water.mp3',
        speakerGender: 'Female',
        sampleDuration: Duration(milliseconds: 900),
      ),
    },
    'sheet': {
      'US': const NativeSpeakerSample(
        word: 'sheet',
        ipa: '/ʃiːt/',
        accent: 'US',
        audioUrl: 'https://assets.speakup.ai/audio/samples/us_sheet.mp3',
        speakerGender: 'Female',
        sampleDuration: Duration(milliseconds: 850),
      ),
      'UK': const NativeSpeakerSample(
        word: 'sheet',
        ipa: '/ʃiːt/',
        accent: 'UK',
        audioUrl: 'https://assets.speakup.ai/audio/samples/uk_sheet.mp3',
        speakerGender: 'Male',
        sampleDuration: Duration(milliseconds: 830),
      ),
    },
    'dogs': {
      'US': const NativeSpeakerSample(
        word: 'dogs',
        ipa: '/dɒɡz/',
        accent: 'US',
        audioUrl: 'https://assets.speakup.ai/audio/samples/us_dogs.mp3',
        speakerGender: 'Male',
        sampleDuration: Duration(milliseconds: 840),
      ),
      'UK': const NativeSpeakerSample(
        word: 'dogs',
        ipa: '/dɒɡz/',
        accent: 'UK',
        audioUrl: 'https://assets.speakup.ai/audio/samples/uk_dogs.mp3',
        speakerGender: 'Female',
        sampleDuration: Duration(milliseconds: 810),
      ),
    },
  };

  /// Bắt đầu phiên thu âm Microphone
  Future<void> startRecording({bool enableNoiseFilter = true}) async {
    _isRecording = true;
    _recordingStartTime = DateTime.now();
    await _recordingManager.startRecording(
      enableNoiseFilter: enableNoiseFilter,
    );
  }

  /// Dừng thu âm và nhận dạng giọng nói thành văn bản kèm mốc thời gian âm vị
  Future<SpeechRecognitionResult> stopRecordingAndRecognize({
    String? mockRecognizedText,
    double mockConfidence = 0.94,
    String engineType = 'WhisperAI',
    bool simulateBackgroundNoise = false,
  }) async {
    if (!_isRecording) {
      throw StateError('Không có phiên thu âm nào đang hoạt động.');
    }

    _isRecording = false;
    final recordedFile = await _recordingManager.stopRecording();
    final duration = DateTime.now().difference(_recordingStartTime ?? DateTime.now());

    // Nếu thời lượng thu âm quá ngắn (< 300ms) hoặc biên độ quá nhỏ: coi như im lặng
    if (duration.inMilliseconds < 300 && mockRecognizedText == null) {
      return SpeechRecognitionResult(
        recognizedText: '',
        confidence: 0.0,
        audioFilePath: recordedFile.filePath,
        recordingDuration: duration,
        isSilent: true,
        engineType: engineType,
      );
    }

    final rawText = mockRecognizedText ?? 'cat';
    final timestamps = generateWordAndPhonemeTimestamps(rawText, duration);

    // Tính toán độ tin cậy thực tế sau khi xem xét yếu tố tạp âm nền
    double effectiveConfidence = mockConfidence;
    if (simulateBackgroundNoise) {
      effectiveConfidence = max(0.60, effectiveConfidence - 0.10);
    }

    return SpeechRecognitionResult(
      recognizedText: rawText,
      confidence: double.parse(effectiveConfidence.toStringAsFixed(2)),
      audioFilePath: recordedFile.filePath,
      recordingDuration: duration,
      wordTimestamps: timestamps,
      engineType: engineType,
      isNoisy: simulateBackgroundNoise,
    );
  }

  /// Thuật toán tự động sinh mốc thời gian căn gióng âm vị và từ vựng (Timestamp Alignment)
  List<SpeechWordTimestamp> generateWordAndPhonemeTimestamps(
    String text,
    Duration totalDuration,
  ) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || text.trim().isEmpty) return [];

    final result = <SpeechWordTimestamp>[];
    final totalMs = max(400, totalDuration.inMilliseconds);
    final msPerWord = totalMs ~/ words.length;

    for (int wIdx = 0; wIdx < words.length; wIdx++) {
      final word = words[wIdx];
      final wordStart = wIdx * msPerWord;
      final wordEnd = wordStart + msPerWord;

      // Tách mốc thời gian cho từng ký tự / âm vị trong từ
      final phonemeList = <SpeechPhonemeTimestamp>[];
      final letters = word.split('');
      if (letters.isNotEmpty) {
        final msPerLetter = (wordEnd - wordStart) ~/ letters.length;
        for (int pIdx = 0; pIdx < letters.length; pIdx++) {
          final pStart = wordStart + pIdx * msPerLetter;
          final pEnd = pStart + msPerLetter;
          phonemeList.add(SpeechPhonemeTimestamp(
            phoneme: letters[pIdx],
            startOffsetMs: pStart,
            endOffsetMs: pEnd,
            confidence: 0.95,
          ));
        }
      }

      result.add(SpeechWordTimestamp(
        word: word,
        startOffsetMs: wordStart,
        endOffsetMs: wordEnd,
        confidence: 0.94,
        phonemeTimestamps: phonemeList,
      ));
    }

    return result;
  }

  /// Bộ tạo dữ liệu sóng âm thời gian thực phục vụ Waveform Visualizer
  Stream<double> get amplitudeStream => _recordingManager.amplitudeStream;

  /// Lấy mẫu phát âm chuẩn người bản xứ của từ vựng
  NativeSpeakerSample? getNativeSample(String word, {String accent = 'US'}) {
    final cleanWord = word.trim().toLowerCase();
    final variants = _nativeSamples[cleanWord];
    if (variants == null) return null;
    return variants[accent] ?? variants['US'];
  }

  /// Phát âm thanh mẫu chuẩn người bản xứ (Native Speaker Audio)
  Future<NativeSpeakerSample> playNativeAudioSample(
    String word, {
    String accent = 'US',
  }) async {
    final sample = getNativeSample(word, accent: accent);
    final targetSample = sample ??
        NativeSpeakerSample(
          word: word,
          ipa: '/$word/',
          accent: accent,
          audioUrl: 'https://assets.speakup.ai/audio/samples/generic_$word.mp3',
          speakerGender: 'Female',
          sampleDuration: const Duration(milliseconds: 800),
        );

    _isPlayingNativeSample = true;
    _nativePlaybackController.add(true);

    // Giả lập thời gian phát âm thanh mẫu
    await Future.delayed(targetSample.sampleDuration);

    _isPlayingNativeSample = false;
    _nativePlaybackController.add(false);

    return targetSample;
  }

  /// Dừng phát âm mẫu
  void stopNativeAudioSample() {
    _isPlayingNativeSample = false;
    _nativePlaybackController.add(false);
  }

  void dispose() {
    _recordingManager.dispose();
    _nativePlaybackController.close();
  }
}
