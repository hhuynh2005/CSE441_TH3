/// ==============================================================================
/// BỘ KIỂM THỬ MOCK AUDIO & SPEECH RECOGNITION (AUDIO TEST SUITE)
/// Phụ trách: NGUYỄN TRUNG KIÊN (2251172394) - Checklist 3 & Sprint 1, 2, 4
/// ==============================================================================

import 'package:test/test.dart';
import '../lib/services/audio_recording_manager.dart';
import '../lib/services/speech_recognition_service.dart';

void main() {
  group('1. AudioRecordingManager Tests (Sprint 1 - Thu Âm & Lọc Nhiễu)', () {
    late AudioRecordingManager recordingManager;

    setUp(() {
      recordingManager = AudioRecordingManager();
    });

    tearDown(() {
      recordingManager.dispose();
    });

    test('TC-AUDIO-01: Cấu hình định dạng âm thanh chuẩn 16kHz mono 16-bit WAV', () {
      final config = recordingManager.config;
      expect(config.sampleRate, equals(16000));
      expect(config.channels, equals(1));
      expect(config.bitDepth, equals(16));
      expect(config.format, equals('WAV'));
    });

    test('TC-AUDIO-02: Ước tính kích thước file WAV chuẩn theo công thức PCM', () {
      final config = recordingManager.config;
      // 1 giây ghi âm 16kHz 16-bit mono = 44 bytes header + (16000 * 2 * 1 * 1) = 32,044 bytes
      final size1s = config.estimateByteSize(const Duration(seconds: 1));
      expect(size1s, equals(44 + 32000));

      // 3 giây ghi âm = 44 + (16000 * 2 * 3) = 96,044 bytes
      final size3s = config.estimateByteSize(const Duration(seconds: 3));
      expect(size3s, equals(44 + 96000));
    });

    test('TC-AUDIO-03: Bắt đầu thu âm và đo thời lượng ghi âm', () async {
      expect(recordingManager.isIdle, isTrue);
      expect(recordingManager.isRecording, isFalse);

      await recordingManager.startRecording();
      expect(recordingManager.isRecording, isTrue);
      expect(recordingManager.state, equals(AudioRecordingState.recording));

      await Future.delayed(const Duration(milliseconds: 150));
      expect(recordingManager.currentDuration.inMilliseconds, greaterThanOrEqualTo(100));

      final file = await recordingManager.stopRecording();
      expect(recordingManager.isIdle, isTrue);
      expect(file.filePath, contains('.wav'));
      expect(file.formatConfig.sampleRate, equals(16000));
      expect(file.duration.inMilliseconds, greaterThanOrEqualTo(100));
      expect(file.fileSizeBytes, greaterThan(44));
    });

    test('TC-AUDIO-04: Tạm dừng và tiếp tục thu âm (Pause / Resume)', () async {
      await recordingManager.startRecording();
      await Future.delayed(const Duration(milliseconds: 100));

      await recordingManager.pauseRecording();
      expect(recordingManager.isPaused, isTrue);
      expect(recordingManager.isRecording, isFalse);

      final pauseDuration1 = recordingManager.currentDuration;
      await Future.delayed(const Duration(milliseconds: 100));
      final pauseDuration2 = recordingManager.currentDuration;
      // Trong lúc tạm dừng, thời lượng không được tăng
      expect((pauseDuration2 - pauseDuration1).inMilliseconds, lessThan(30));

      await recordingManager.resumeRecording();
      expect(recordingManager.isRecording, isTrue);

      final file = await recordingManager.stopRecording();
      expect(file.duration.inMilliseconds, greaterThan(0));
    });

    test('TC-AUDIO-05: Thuật toán lọc nhiễu môi trường Noise Gate', () {
      const threshold = 0.12;

      // Tiếng ồn nền nhỏ hơn ngưỡng threshold -> Triệt tiêu về mức nền 0.02
      final suppressedNoise1 = recordingManager.filterNoiseSample(0.05, threshold: threshold);
      final suppressedNoise2 = recordingManager.filterNoiseSample(0.10, threshold: threshold);
      expect(suppressedNoise1, equals(0.02));
      expect(suppressedNoise2, equals(0.02));

      // Giọng nói lớn hơn ngưỡng threshold -> Giữ lại và chuẩn hóa
      final speechSample = recordingManager.filterNoiseSample(0.50, threshold: threshold);
      expect(speechSample, greaterThan(0.02));
      expect(speechSample, lessThanOrEqualTo(1.0));
    });

    test('TC-AUDIO-06: Lọc nhiễu theo khối (Batch Processing & Moving Average)', () {
      final rawSamples = [0.05, 0.08, 0.65, 0.85, 0.70, 0.06, 0.04];
      final filtered = recordingManager.applyNoiseFilterBatch(rawSamples, gateThreshold: 0.12);

      expect(filtered.length, equals(rawSamples.length));
      // Hai mẫu đầu và hai mẫu cuối là tiếng ồn nhỏ hơn threshold phải được triệt tiêu
      expect(filtered.first, lessThan(0.1));
      expect(filtered.last, lessThan(0.1));
      // Các mẫu ở giữa là giọng nói phải có biên độ cao
      expect(filtered[3], greaterThan(0.5));
    });

    test('TC-AUDIO-07: Sinh Header WAV 44-byte chuẩn hóa', () {
      final header = recordingManager.generateWavHeader(
        pcmDataLength: 32000,
        sampleRate: 16000,
        channels: 1,
        bitDepth: 16,
      );

      expect(header.length, equals(44));
      // Ký tự 'RIFF'
      expect(String.fromCharCodes(header.sublist(0, 4)), equals('RIFF'));
      // Ký tự 'WAVE'
      expect(String.fromCharCodes(header.sublist(8, 12)), equals('WAVE'));
      // Ký tự 'fmt '
      expect(String.fromCharCodes(header.sublist(12, 16)), equals('fmt '));
      // Ký tự 'data'
      expect(String.fromCharCodes(header.sublist(36, 40)), equals('data'));

      // Kiểm tra giá trị sampleRate 16000 ở byte 24-27
      final sr = header[24] | (header[25] << 8) | (header[26] << 16) | (header[27] << 24);
      expect(sr, equals(16000));
    });
  });

  group('2. SpeechRecognitionService Tests (Sprint 2 - STT & Timestamps)', () {
    late SpeechRecognitionService speechService;

    setUp(() {
      speechService = SpeechRecognitionService();
    });

    tearDown(() {
      speechService.dispose();
    });

    test('TC-STT-01: Nhận diện giọng nói chuẩn thành chuỗi văn bản với độ tin cậy cao', () async {
      await speechService.startRecording();
      await Future.delayed(const Duration(milliseconds: 350));

      final result = await speechService.stopRecordingAndRecognize(
        mockRecognizedText: 'cat',
        mockConfidence: 0.96,
        engineType: 'WhisperAI',
      );

      expect(result.recognizedText, equals('cat'));
      expect(result.confidence, equals(0.96));
      expect(result.isSilent, isFalse);
      expect(result.engineType, equals('WhisperAI'));
      expect(result.wordTimestamps.isNotEmpty, isTrue);
    });

    test('TC-STT-02: Tự động phân tách mốc thời gian từ và âm vị (Alignment Timestamps)', () {
      final timestamps = speechService.generateWordAndPhonemeTimestamps(
        'cat',
        const Duration(milliseconds: 800),
      );

      expect(timestamps.length, equals(1));
      final wordToken = timestamps.first;
      expect(wordToken.word, equals('cat'));
      expect(wordToken.startOffsetMs, equals(0));
      expect(wordToken.endOffsetMs, equals(800));

      // 3 ký tự c, a, t
      expect(wordToken.phonemeTimestamps.length, equals(3));
      expect(wordToken.phonemeTimestamps[0].phoneme, equals('c'));
      expect(wordToken.phonemeTimestamps[1].phoneme, equals('a'));
      expect(wordToken.phonemeTimestamps[2].phoneme, equals('t'));
    });

    test('TC-STT-03: Phát hiện khoảng lặng (Silence) khi không có âm thanh', () async {
      await speechService.startRecording();
      // Ngắt ngay tức khắc (< 300ms) không truyền text mock
      final result = await speechService.stopRecordingAndRecognize();

      expect(result.isSilent, isTrue);
      expect(result.recognizedText.isEmpty, isTrue);
      expect(result.confidence, equals(0.0));
    });

    test('TC-STT-04: Xử lý tạp âm nền (Quán Cafe ồn ào)', () async {
      await speechService.startRecording();
      await Future.delayed(const Duration(milliseconds: 350));

      final result = await speechService.stopRecordingAndRecognize(
        mockRecognizedText: 'dogs',
        mockConfidence: 0.92,
        simulateBackgroundNoise: true,
      );

      expect(result.recognizedText, equals('dogs'));
      expect(result.isNoisy, isTrue);
      expect(result.confidence, lessThan(0.92));
    });

    test('TC-STT-05: Phát âm mẫu chuẩn bản xứ Native Speaker Audio (US & UK)', () async {
      final usSample = speechService.getNativeSample('water', accent: 'US');
      expect(usSample, isNotNull);
      expect(usSample!.accent, equals('US'));
      expect(usSample.ipa, contains('wɔːtər'));

      final ukSample = speechService.getNativeSample('water', accent: 'UK');
      expect(ukSample, isNotNull);
      expect(ukSample!.accent, equals('UK'));
      expect(ukSample.ipa, contains('wɔːtə'));

      // Kiểm tra phát âm thanh mẫu
      final played = await speechService.playNativeAudioSample('cat', accent: 'US');
      expect(played.word, equals('cat'));
      expect(speechService.isPlayingNativeSample, isFalse);
    });
  });

  group('3. Multi-Accent Integration Tests (Sprint 4 & Checklist 7)', () {
    late SpeechRecognitionService speechService;

    setUp(() {
      speechService = SpeechRecognitionService();
    });

    tearDown(() {
      speechService.dispose();
    });

    test('TC-MULTI-01: Nhận diện giọng Việt phát âm chuẩn từ "cat"', () async {
      await speechService.startRecording();
      await Future.delayed(const Duration(milliseconds: 320));

      final result = await speechService.stopRecordingAndRecognize(
        mockRecognizedText: 'cat',
        mockConfidence: 0.95,
      );

      expect(result.recognizedText, equals('cat'));
      expect(result.confidence, greaterThanOrEqualTo(0.90));
    });

    test('TC-MULTI-02: Nhận diện giọng Việt nuốt âm đuôi "cats" thành "cat"', () async {
      await speechService.startRecording();
      await Future.delayed(const Duration(milliseconds: 320));

      final result = await speechService.stopRecordingAndRecognize(
        mockRecognizedText: 'cat', // Học viên nuốt mất phụ âm đuôi /s/
        mockConfidence: 0.88,
      );

      expect(result.recognizedText, equals('cat'));
      expect(result.wordTimestamps.first.phonemeTimestamps.map((p) => p.phoneme).toList(),
          equals(['c', 'a', 't']));
    });

    test('TC-MULTI-03: Nhận diện giọng bản xứ US từ "think" với âm /θ/', () async {
      await speechService.startRecording();
      await Future.delayed(const Duration(milliseconds: 320));

      final result = await speechService.stopRecordingAndRecognize(
        mockRecognizedText: 'think',
        mockConfidence: 0.98,
      );

      expect(result.recognizedText, equals('think'));
      expect(result.confidence, greaterThanOrEqualTo(0.95));
    });
  });
}
