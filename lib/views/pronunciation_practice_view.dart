/// ==============================================================================
/// GIAO DIỆN MÀN HÌNH LUYỆN PHÁT ÂM TIẾNG ANH (PRONUNCIATION PRACTICE VIEW)
/// Phụ trách: NGUYỄN TRUNG KIÊN (2251172394) - Checklist 3 & Sprint 3
/// ==============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/speech_recognition_service.dart';
import '../services/phoneme_comparison_engine.dart';
import '../models/pronunciation_result_model.dart';
import '../widgets/waveform_visualizer.dart';
import '../widgets/phoneme_feedback_widget.dart';
import '../services/web_audio_helper.dart' as web_audio;

/// Mục từ vựng luyện tập
class PracticeItem {
  final String word;
  final String ipa;
  final String meaningVi;
  final String exampleSentence;

  const PracticeItem({
    required this.word,
    required this.ipa,
    required this.meaningVi,
    required this.exampleSentence,
  });
}

class PronunciationPracticeView extends StatefulWidget {
  final List<PracticeItem>? practiceList;
  final SpeechRecognitionService? speechService;
  final PhonemeComparisonEngine? phonemeEngine;

  const PronunciationPracticeView({
    Key? key,
    this.practiceList,
    this.speechService,
    this.phonemeEngine,
  }) : super(key: key);

  @override
  State<PronunciationPracticeView> createState() => _PronunciationPracticeViewState();
}

class _PronunciationPracticeViewState extends State<PronunciationPracticeView>
    with SingleTickerProviderStateMixin {
  late final SpeechRecognitionService _speechService;
  late final PhonemeComparisonEngine _phonemeEngine;

  late final List<PracticeItem> _practiceList;
  int _currentIndex = 0;

  bool _isRecording = false;
  bool _isProcessingAI = false;
  bool _isPlayingUserAudio = false;
  double _playbackProgress = 0.0;
  Timer? _playbackTimer;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  String _selectedAccent = 'US'; // 'US' hoặc 'UK'
  SpeechRecognitionResult? _lastRecognitionResult;
  PronunciationResult? _lastPronunciationResult;

  late AnimationController _micPulseController;
  late Animation<double> _micPulseAnimation;

  @override
  void initState() {
    super.initState();
    _speechService = widget.speechService ?? SpeechRecognitionService();
    _phonemeEngine = widget.phonemeEngine ?? PhonemeComparisonEngine();

    _practiceList = widget.practiceList ??
        const [
          PracticeItem(
            word: 'cat',
            ipa: '/kæt/',
            meaningVi: 'Con mèo (âm ngắn /æ/, bật hơi dứt khoát /t/)',
            exampleSentence: 'The cat is sitting on the mat.',
          ),
          PracticeItem(
            word: 'cats',
            ipa: '/kæts/',
            meaningVi: 'Những con mèo (chú ý bật rõ phụ âm đuôi /s/)',
            exampleSentence: 'Two cats are playing in the garden.',
          ),
          PracticeItem(
            word: 'think',
            ipa: '/θɪŋk/',
            meaningVi: 'Suy nghĩ (đặt lưỡi giữa hai hàm răng âm /θ/)',
            exampleSentence: 'I think this is a great idea.',
          ),
          PracticeItem(
            word: 'water',
            ipa: '/ˈwɔːtər/',
            meaningVi: 'Nước uống (phân biệt âm uốn lưỡi US và không uốn lưỡi UK)',
            exampleSentence: 'Drink a glass of water every morning.',
          ),
          PracticeItem(
            word: 'sheet',
            ipa: '/ʃiːt/',
            meaningVi: 'Tờ giấy, khăn trải (nguyên âm dài /i:/, kéo rộng khóe miệng)',
            exampleSentence: 'Please take a clean sheet of paper.',
          ),
          PracticeItem(
            word: 'dogs',
            ipa: '/dɒɡz/',
            meaningVi: 'Những con chó (phụ âm đuôi rung /z/)',
            exampleSentence: 'The dogs are barking outside.',
          ),
        ];

    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _micPulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _micPulseController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  PracticeItem get _currentWord => _practiceList[_currentIndex];

  /// Bắt đầu hoặc dừng thu âm Microphone
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _lastPronunciationResult = null;
      _lastRecognitionResult = null;
      _isPlayingUserAudio = false;
      _playbackProgress = 0.0;
    });

    _playbackTimer?.cancel();
    web_audio.startWebRecording();
    await _speechService.startRecording(enableNoiseFilter: true);

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _recordingSeconds++;
      });
      // Tự động dừng nếu thu âm quá 8 giây
      if (_recordingSeconds >= 8) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    web_audio.stopWebRecording();
    setState(() {
      _isRecording = false;
      _isProcessingAI = true;
    });

    try {
      // Dừng thu âm và nhận diện giọng nói STT
      final result = await _speechService.stopRecordingAndRecognize(
        mockRecognizedText: _currentWord.word,
        mockConfidence: 0.95,
      );

      // Phân tích và chấm điểm âm vị AI
      final evaluation = _phonemeEngine.analyzePronunciation(
        targetWord: _currentWord.word,
        userRecognizedText: result.recognizedText,
      );

      if (mounted) {
        setState(() {
          _lastRecognitionResult = result;
          _lastPronunciationResult = evaluation;
          _isProcessingAI = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingAI = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xử lý âm thanh: $e')),
        );
      }
    }
  }

  /// Phát âm thanh mẫu của người bản xứ (Native Speaker Audio)
  Future<void> _playNativeSample() async {
    if (_speechService.isPlayingNativeSample) {
      _speechService.stopNativeAudioSample();
      setState(() {});
      return;
    }

    setState(() {});
    web_audio.speakWord(_currentWord.word, lang: _selectedAccent);
    await _speechService.playNativeAudioSample(
      _currentWord.word,
      accent: _selectedAccent,
    );
    if (mounted) {
      setState(() {});
    }
  }

  /// Phát lại đoạn âm thanh học viên vừa tự thu âm (Audio Player Controller)
  void _togglePlayUserAudio() {
    if (_isPlayingUserAudio) {
      _playbackTimer?.cancel();
      web_audio.stopRecordedAudio();
      setState(() {
        _isPlayingUserAudio = false;
      });
      return;
    }

    web_audio.playRecordedAudio();
    setState(() {
      _isPlayingUserAudio = true;
      _playbackProgress = 0.0;
    });

    final durationSeconds = _lastRecognitionResult?.recordingDuration.inSeconds ?? 2;
    final totalSteps = (durationSeconds > 0 ? durationSeconds : 2) * 25;
    int currentStep = 0;
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      currentStep++;
      setState(() {
        _playbackProgress = currentStep / totalSteps;
      });

      if (currentStep >= totalSteps) {
        timer.cancel();
        web_audio.stopRecordedAudio();
        setState(() {
          _isPlayingUserAudio = false;
          _playbackProgress = 1.0;
        });
      }
    });
  }

  void _nextWord() {
    if (_currentIndex < _practiceList.length - 1) {
      setState(() {
        _currentIndex++;
        _lastPronunciationResult = null;
        _lastRecognitionResult = null;
        _isPlayingUserAudio = false;
        _playbackProgress = 0.0;
      });
    }
  }

  void _prevWord() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _lastPronunciationResult = null;
        _lastRecognitionResult = null;
        _isPlayingUserAudio = false;
        _playbackProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayingNative = _speechService.isPlayingNativeSample;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Luyện Phát Âm Tiếng Anh AI'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Nút chọn Accent US / UK
          PopupMenuButton<String>(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  _selectedAccent,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            onSelected: (accent) {
              setState(() {
                _selectedAccent = accent;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'US', child: Text('Giọng Anh - Mỹ (US)')),
              const PopupMenuItem(value: 'UK', child: Text('Giọng Anh - Anh (UK)')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh chuyển từ và đếm tiến trình
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentIndex > 0 ? _prevWord : null,
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  tooltip: 'Từ trước',
                ),
                Text(
                  'Từ ${_currentIndex + 1} / ${_practiceList.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                IconButton(
                  onPressed: _currentIndex < _practiceList.length - 1 ? _nextWord : null,
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  tooltip: 'Từ kế tiếp',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Card hiển thị Từ vựng mục tiêu & Phiên âm IPA
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      _currentWord.word,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentWord.ipa,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentWord.meaningVi,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),

                    // Nút nghe phát âm mẫu bản xứ
                    OutlinedButton.icon(
                      onPressed: _isRecording ? null : _playNativeSample,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        side: BorderSide(
                          color: isPlayingNative ? Colors.green : theme.colorScheme.primary,
                        ),
                      ),
                      icon: Icon(
                        isPlayingNative ? Icons.volume_up : Icons.play_circle_outline,
                        color: isPlayingNative ? Colors.green : theme.colorScheme.primary,
                      ),
                      label: Text(
                        isPlayingNative
                            ? 'Đang phát mẫu ($_selectedAccent)...'
                            : 'Nghe phát âm chuẩn ($_selectedAccent)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isPlayingNative ? Colors.green : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bộ hiển thị sóng âm thời gian thực Waveform Visualizer
            WaveformVisualizerWidget(
              isRecording: _isRecording,
              isPlaying: _isPlayingUserAudio,
              amplitudeStream: _speechService.amplitudeStream,
              playbackProgress: _playbackProgress,
              height: 90,
            ),
            const SizedBox(height: 24),

            // Nút bấm Microphone thu âm lớn ở trung tâm
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isProcessingAI ? null : _toggleRecording,
                    child: ScaleTransition(
                      scale: _isRecording ? _micPulseAnimation : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.redAccent : theme.colorScheme.primary,
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.redAccent : theme.colorScheme.primary)
                                  .withValues(alpha: 0.35),
                              blurRadius: 20,
                              spreadRadius: _isRecording ? 6 : 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isRecording
                        ? 'Đang thu âm: 00:0${_recordingSeconds}s (Nhấn để dừng)'
                        : _isProcessingAI
                            ? 'AI đang phân tích âm vị...'
                            : 'Chạm vào Micro để bắt đầu luyện nói',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isRecording ? Colors.redAccent : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bộ điều khiển phát lại giọng đọc của học viên (Audio Player Controls)
            if (_lastRecognitionResult != null && !_isRecording) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueGrey.shade200),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _togglePlayUserAudio,
                      icon: Icon(
                        _isPlayingUserAudio ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.blue.shade700,
                        size: 38,
                      ),
                      tooltip: 'Nghe lại giọng đọc của bạn',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bản ghi giọng của bạn',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: _playbackProgress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_lastRecognitionResult!.recordingDuration.inSeconds} giây',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              Text(
                                'STT: "${_lastRecognitionResult!.recognizedText}"',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _startRecording,
                      icon: const Icon(Icons.refresh, color: Colors.orange),
                      tooltip: 'Thu âm lại từ này',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Kết quả chấm điểm âm vị AI (Phoneme Feedback Widget)
            if (_lastPronunciationResult != null)
              PhonemeFeedbackWidget(result: _lastPronunciationResult!),
          ],
        ),
      ),
    );
  }
}
