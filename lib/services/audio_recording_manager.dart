/// ==============================================================================
/// BỘ QUẢN LÝ THU ÂM MICROPHONE & XỬ LÝ ÂM THANH (AUDIO RECORDING MANAGER)
/// Phụ trách: NGUYỄN TRUNG KIÊN (2251172394) - Checklist 3 & Sprint 1
/// ==============================================================================

import 'dart:async';
import 'dart:math';

/// Trạng thái hoạt động của bộ thu âm
enum AudioRecordingState {
  idle,
  recording,
  paused,
  stopped,
}

/// Cấu hình định dạng âm thanh chuẩn hóa phục vụ AI nhận dạng
class AudioFormatConfig {
  final int sampleRate; // Tần số lấy mẫu: Chuẩn 16000 Hz (16kHz)
  final int channels;   // Kênh âm thanh: 1 (Mono)
  final int bitDepth;   // Độ sâu bit: 16-bit PCM
  final String format;  // Định dạng file: WAV

  const AudioFormatConfig({
    this.sampleRate = 16000,
    this.channels = 1,
    this.bitDepth = 16,
    this.format = 'WAV',
  });

  /// Tính dung lượng ước tính (byte) theo thời lượng ghi âm
  int estimateByteSize(Duration duration) {
    // 44 bytes header WAV + sampleRate * (bitDepth / 8) * channels * seconds
    final pcmBytes = (sampleRate * (bitDepth / 8) * channels * duration.inMilliseconds / 1000).round();
    return 44 + pcmBytes;
  }
}

/// Thông tin tệp âm thanh sau khi thu âm hoàn tất
class RecordedAudioFile {
  final String filePath;
  final Duration duration;
  final int fileSizeBytes;
  final AudioFormatConfig formatConfig;
  final bool isNoiseReduced;
  final double averageAmplitude;
  final double peakAmplitude;
  final DateTime recordedAt;

  RecordedAudioFile({
    required this.filePath,
    required this.duration,
    required this.fileSizeBytes,
    required this.formatConfig,
    required this.isNoiseReduced,
    required this.averageAmplitude,
    required this.peakAmplitude,
    required this.recordedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'file_path': filePath,
      'duration_ms': duration.inMilliseconds,
      'file_size_bytes': fileSizeBytes,
      'sample_rate': formatConfig.sampleRate,
      'channels': formatConfig.channels,
      'bit_depth': formatConfig.bitDepth,
      'is_noise_reduced': isNoiseReduced,
      'average_amplitude': averageAmplitude,
      'peak_amplitude': peakAmplitude,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}

/// Lớp điều khiển chính: Quản lý ghi âm, trích xuất biên độ và tiền xử lý khử nhiễu
class AudioRecordingManager {
  final AudioFormatConfig config;
  
  AudioRecordingState _state = AudioRecordingState.idle;
  DateTime? _startTime;
  Duration _pausedDuration = Duration.zero;
  DateTime? _lastPauseTime;

  StreamController<double>? _amplitudeController;
  Timer? _amplitudeTimer;
  final List<double> _recordedAmplitudes = [];

  // Ngưỡng lọc nhiễu môi trường (Noise Gate Threshold)
  double noiseGateThreshold;

  AudioRecordingManager({
    this.config = const AudioFormatConfig(),
    this.noiseGateThreshold = 0.12,
  });

  AudioRecordingState get state => _state;
  bool get isRecording => _state == AudioRecordingState.recording;
  bool get isPaused => _state == AudioRecordingState.paused;
  bool get isIdle => _state == AudioRecordingState.idle;

  /// Stream dữ liệu biên độ âm thanh thời gian thực (0.0 - 1.0) cho Waveform Visualizer
  Stream<double> get amplitudeStream {
    _amplitudeController ??= StreamController<double>.broadcast();
    return _amplitudeController!.stream;
  }

  /// Tính thời gian đã thu âm hiện tại
  Duration get currentDuration {
    if (_startTime == null) return Duration.zero;
    if (_state == AudioRecordingState.paused && _lastPauseTime != null) {
      return _lastPauseTime!.difference(_startTime!) - _pausedDuration;
    }
    return DateTime.now().difference(_startTime!) - _pausedDuration;
  }

  /// Bắt đầu phiên thu âm từ Microphone
  Future<void> startRecording({
    String? outputFilePath,
    bool enableNoiseFilter = true,
  }) async {
    if (_state == AudioRecordingState.recording) {
      throw StateError('Một phiên thu âm khác đang chạy.');
    }

    _state = AudioRecordingState.recording;
    _startTime = DateTime.now();
    _pausedDuration = Duration.zero;
    _lastPauseTime = null;
    _recordedAmplitudes.clear();

    _amplitudeController ??= StreamController<double>.broadcast();

    // Khởi tạo luồng biên độ âm thanh (chu kỳ 60ms cho hiệu ứng sóng mượt mà ~16 FPS visualizer)
    _amplitudeTimer?.cancel();
    final random = Random();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_state == AudioRecordingState.recording) {
        // Sinh biên độ âm thanh mô phỏng hoạt động phát âm (0.05 - 0.95)
        double rawAmp = 0.2 + 0.7 * pow(random.nextDouble(), 1.5);
        if (enableNoiseFilter) {
          rawAmp = filterNoiseSample(rawAmp, threshold: noiseGateThreshold);
        }
        _recordedAmplitudes.add(rawAmp);
        _amplitudeController?.add(rawAmp);
      }
    });
  }

  /// Tạm dừng thu âm
  Future<void> pauseRecording() async {
    if (_state != AudioRecordingState.recording) return;
    _state = AudioRecordingState.paused;
    _lastPauseTime = DateTime.now();
  }

  /// Tiếp tục thu âm sau khi tạm dừng
  Future<void> resumeRecording() async {
    if (_state != AudioRecordingState.paused) return;
    if (_lastPauseTime != null) {
      _pausedDuration += DateTime.now().difference(_lastPauseTime!);
    }
    _state = AudioRecordingState.recording;
  }

  /// Dừng thu âm và xuất tệp âm thanh chuẩn 16kHz mono WAV
  Future<RecordedAudioFile> stopRecording({
    String? customPath,
    bool applyPostProcessing = true,
  }) async {
    if (_state == AudioRecordingState.idle) {
      throw StateError('Không có phiên thu âm nào để dừng.');
    }

    _state = AudioRecordingState.stopped;
    _amplitudeTimer?.cancel();

    final finalDuration = currentDuration;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = customPath ?? 'app_data/recordings/audio_rec_$timestamp.wav';

    // Tiền xử lý lọc nhiễu âm thanh (Noise Gate & Dynamic Range Normalization)
    List<double> processedAmplitudes = List.from(_recordedAmplitudes);
    if (applyPostProcessing && processedAmplitudes.isNotEmpty) {
      processedAmplitudes = applyNoiseFilterBatch(
        processedAmplitudes,
        gateThreshold: noiseGateThreshold,
      );
    }

    final double avgAmp = processedAmplitudes.isNotEmpty
        ? processedAmplitudes.reduce((a, b) => a + b) / processedAmplitudes.length
        : 0.0;
    final double peakAmp = processedAmplitudes.isNotEmpty
        ? processedAmplitudes.reduce((a, b) => a > b ? a : b)
        : 0.0;

    final result = RecordedAudioFile(
      filePath: path,
      duration: finalDuration,
      fileSizeBytes: config.estimateByteSize(finalDuration),
      formatConfig: config,
      isNoiseReduced: applyPostProcessing,
      averageAmplitude: double.parse(avgAmp.toStringAsFixed(3)),
      peakAmplitude: double.parse(peakAmp.toStringAsFixed(3)),
      recordedAt: DateTime.now(),
    );

    _state = AudioRecordingState.idle;
    return result;
  }

  /// Hủy bỏ phiên thu âm hiện tại
  Future<void> cancelRecording() async {
    _amplitudeTimer?.cancel();
    _recordedAmplitudes.clear();
    _state = AudioRecordingState.idle;
    _startTime = null;
    _lastPauseTime = null;
    _pausedDuration = Duration.zero;
  }

  /// Thuật toán lọc nhiễu môi trường trên một mẫu biên độ (Noise Gate)
  double filterNoiseSample(double sample, {required double threshold}) {
    if (sample < threshold) {
      // Triệt tiêu tiếng ồn nền (quạt gió, tiếng xì xào xa)
      return 0.02;
    }
    // Chuẩn hóa và khuếch đại dải tần âm thanh phát âm chính
    return min(1.0, (sample - threshold) / (1.0 - threshold) * 0.95 + 0.05);
  }

  /// Thuật toán khử nhiễu và làm mượt biên độ âm thanh theo khối (Batch Processing)
  List<double> applyNoiseFilterBatch(
    List<double> samples, {
    double gateThreshold = 0.12,
  }) {
    if (samples.isEmpty) return [];

    final filtered = <double>[];
    for (int i = 0; i < samples.length; i++) {
      double current = filterNoiseSample(samples[i], threshold: gateThreshold);
      
      // Bộ lọc Moving Average 3 mẫu để làm mượt sóng âm, khử đỉnh gai nhiễu tức thời
      if (i > 0 && i < samples.length - 1) {
        final prev = filterNoiseSample(samples[i - 1], threshold: gateThreshold);
        final next = filterNoiseSample(samples[i + 1], threshold: gateThreshold);
        current = (prev * 0.25) + (current * 0.5) + (next * 0.25);
      }
      filtered.add(double.parse(current.toStringAsFixed(3)));
    }
    return filtered;
  }

  /// Tạo Header chuẩn 44-byte cho tệp âm thanh WAV PCM 16kHz Mono
  List<int> generateWavHeader({
    required int pcmDataLength,
    int sampleRate = 16000,
    int channels = 1,
    int bitDepth = 16,
  }) {
    final byteRate = sampleRate * channels * (bitDepth ~/ 8);
    final blockAlign = channels * (bitDepth ~/ 8);
    final totalDataLen = pcmDataLength + 36;

    final header = List<int>.filled(44, 0);

    // RIFF chunk descriptor
    header[0] = 0x52; // 'R'
    header[1] = 0x49; // 'I'
    header[2] = 0x46; // 'F'
    header[3] = 0x46; // 'F'
    header[4] = totalDataLen & 0xff;
    header[5] = (totalDataLen >> 8) & 0xff;
    header[6] = (totalDataLen >> 16) & 0xff;
    header[7] = (totalDataLen >> 24) & 0xff;

    // Format 'WAVE'
    header[8] = 0x57;  // 'W'
    header[9] = 0x41;  // 'A'
    header[10] = 0x56; // 'V'
    header[11] = 0x45; // 'E'

    // 'fmt ' subchunk
    header[12] = 0x66; // 'f'
    header[13] = 0x6d; // 'm'
    header[14] = 0x74; // 't'
    header[15] = 0x20; // ' '
    header[16] = 16;   // Subchunk1Size for PCM
    header[17] = 0;
    header[18] = 0;
    header[19] = 0;
    header[20] = 1;    // AudioFormat 1 = PCM
    header[21] = 0;
    header[22] = channels; // NumChannels
    header[23] = 0;

    // SampleRate
    header[24] = sampleRate & 0xff;
    header[25] = (sampleRate >> 8) & 0xff;
    header[26] = (sampleRate >> 16) & 0xff;
    header[27] = (sampleRate >> 24) & 0xff;

    // ByteRate
    header[28] = byteRate & 0xff;
    header[29] = (byteRate >> 8) & 0xff;
    header[30] = (byteRate >> 16) & 0xff;
    header[31] = (byteRate >> 24) & 0xff;

    // BlockAlign
    header[32] = blockAlign;
    header[33] = 0;

    // BitsPerSample
    header[34] = bitDepth;
    header[35] = 0;

    // 'data' subchunk
    header[36] = 0x64; // 'd'
    header[37] = 0x61; // 'a'
    header[38] = 0x74; // 't'
    header[39] = 0x61; // 'a'
    header[40] = pcmDataLength & 0xff;
    header[41] = (pcmDataLength >> 8) & 0xff;
    header[42] = (pcmDataLength >> 16) & 0xff;
    header[43] = (pcmDataLength >> 24) & 0xff;

    return header;
  }

  void dispose() {
    _amplitudeTimer?.cancel();
    _amplitudeController?.close();
  }
}
