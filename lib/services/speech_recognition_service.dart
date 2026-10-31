/// ==============================================================================
/// DỊCH VỤ NHẬN DẠNG GIỌNG NÓI & XỬ LÝ ÂM THANH (SPEECH RECOGNITION SERVICE)
/// Phụ trách: NGUYỄN TRUNG KIÊN (2251172394) - Mục Checklist 3
/// ==============================================================================

import 'dart:async';

class SpeechRecognitionResult {
  final String recognizedText;
  final double confidence; // Độ tin cậy (0.0 - 1.0)
  final String audioFilePath;
  final Duration recordingDuration;

  SpeechRecognitionResult({
    required this.recognizedText,
    required this.confidence,
    required this.audioFilePath,
    required this.recordingDuration,
  });
}

class SpeechRecognitionService {
  bool _isRecording = false;
  DateTime? _recordingStartTime;

  bool get isRecording => _isRecording;

  /// Bắt đầu phiên thu âm Microphone
  Future<void> startRecording() async {
    _isRecording = true;
    _recordingStartTime = DateTime.now();
    // Giả lập cấu hình luồng Microphone: Sample rate 16000Hz, Mono, 16-bit PCM WAV
  }

  /// Dừng thu âm và gửi luồng âm thanh đến API Nhận dạng giọng nói
  Future<SpeechRecognitionResult> stopRecordingAndRecognize({
    String? mockRecognizedText,
    double mockConfidence = 0.94,
  }) async {
    if (!_isRecording) {
      throw StateError('Không có phiên thu âm nào đang hoạt động.');
    }

    _isRecording = false;
    final duration = DateTime.now().difference(_recordingStartTime ?? DateTime.now());

    // Trong môi trường thực tế: gửi tệp WAV lên Google Cloud Speech-to-Text hoặc Whisper AI
    final textResult = mockRecognizedText ?? 'cats';

    return SpeechRecognitionResult(
      recognizedText: textResult,
      confidence: mockConfidence,
      audioFilePath: 'app_data/recordings/sample_${DateTime.now().millisecondsSinceEpoch}.wav',
      recordingDuration: duration,
    );
  }

  /// Bộ tạo dữ liệu sóng âm giả lập (Waveform Stream) phục vụ Waveform Visualizer
  Stream<double> get simulatedAmplitudeStream async* {
    while (_isRecording) {
      await Future.delayed(const Duration(milliseconds: 100));
      // Trả về biên độ âm thanh ngẫu nhiên từ 0.1 đến 1.0 khi người dùng đang nói
      yield (DateTime.now().millisecond % 90 + 10) / 100.0;
    }
  }

  /// Phát âm thanh mẫu chuẩn người bản xứ (Native Speaker Audio)
  Future<void> playNativeAudioSample(String word) async {
    // Tích hợp Text-to-Speech (TTS) hoặc phát file audio mẫu URL từ CSDL
  }
}
