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
  final String category; // 'Phonemes', 'Workplace', 'Travel', 'Technology', 'Sentences'

  const PracticeItem({
    required this.word,
    required this.ipa,
    required this.meaningVi,
    required this.exampleSentence,
    this.category = 'Phonemes',
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

  late List<PracticeItem> _allPracticeList;
  String _selectedCategory = 'All'; // 'All', 'Phonemes', 'Workplace', 'Travel', 'Technology', 'Sentences'
  int _currentIndex = 0;

  bool _isRecording = false;
  bool _isProcessingAI = false;
  bool _isPlayingUserAudio = false;
  double _playbackProgress = 0.0;
  Timer? _playbackTimer;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  String _selectedAccent = 'US'; // 'US' hoặc 'UK'
  String _inputMode = 'mic'; // 'mic', 'perfect', 'missed_ending', 'wrong_vowel', 'silent'
  SpeechRecognitionResult? _lastRecognitionResult;
  PronunciationResult? _lastPronunciationResult;

  late AnimationController _micPulseController;
  late Animation<double> _micPulseAnimation;

  @override
  void initState() {
    super.initState();
    _speechService = widget.speechService ?? SpeechRecognitionService();
    _phonemeEngine = widget.phonemeEngine ?? PhonemeComparisonEngine();

    _allPracticeList = widget.practiceList != null
        ? List<PracticeItem>.from(widget.practiceList!)
        : [
            // ================================================================
            // 1. Âm vị dễ nhầm (Confusing Phonemes) - 10 từ
            // ================================================================
            const PracticeItem(
              word: 'cat',
              ipa: '/kæt/',
              meaningVi: 'Con mèo (âm ngắn /æ/, hạ cằm, bật hơi dứt khoát /t/)',
              exampleSentence: 'The cat is sitting on the mat.',
              category: 'Phonemes',
            ),
            const PracticeItem(
              word: 'cats',
              ipa: '/kæts/',
              meaningVi: 'Những con mèo (chú ý bật rõ phụ âm đuôi /s/)',
              exampleSentence: 'Two cats are playing in the garden.',
              category: 'Phonemes',
            ),
            const PracticeItem(
              word: 'ship',
              ipa: '/ʃɪp/',
              meaningVi: 'Tàu thủy (nguyên âm ngắn /ɪ/, chu môi âm /ʃ/)',
              exampleSentence: 'A large cruise ship arrived at port.',
              category: 'Phonemes',
            ),
            const PracticeItem(
              word: 'sheep',
              ipa: '/ʃiːp/',
              meaningVi: 'Con cừu (nguyên âm dài /i:/, kéo rộng khóe miệng cười)',
              exampleSentence: 'The sheep are grazing on the green hill.',
              category: 'Phonemes',
            ),
            const PracticeItem(
              word: 'sheet',
              ipa: '/ʃiːt/',
              meaningVi: 'Tờ giấy, khăn trải (nguyên âm dài /i:/, bật rõ âm /t/)',
              exampleSentence: 'Please take a clean sheet of paper.',
              category: 'Phonemes',
            ),
            const PracticeItem(
              word: 'think',
              ipa: '/θɪŋk/',
              meaningVi: 'Suy nghĩ (đặt lưỡi giữa hai hàm răng âm /θ/)',
              exampleSentence: 'I think this is a great idea.',
              category: 'Phonemes',
            ),
            const PracticeItem(
              word: 'that',
              ipa: '/ðæt/',
              meaningVi: 'Cái đó (âm rung /ð/, đặt đầu lưỡi giữa hai hàm răng)',
              exampleSentence: 'Look at that beautiful sunset over there.',
              category: 'Phonemes',
            ),
            const PracticeItem(
              word: 'water',
              ipa: '/ˈwɔːtər/',
              meaningVi: 'Nước uống (phân biệt âm uốn lưỡi US và không uốn lưỡi UK)',
              exampleSentence: 'Drink a glass of water every morning.',
              category: 'Phonemes',
            ),
            const PracticeItem(
              word: 'dogs',
              ipa: '/dɒɡz/',
              meaningVi: 'Những con chó (phụ âm đuôi rung /z/)',
              exampleSentence: 'The dogs are barking outside.',
              category: 'Phonemes',
            ),
            const PracticeItem(
              word: 'vision',
              ipa: '/ˈvɪʒn/',
              meaningVi: 'Tầm nhìn (âm rung /ʒ/ như chữ "gi" trong tiếng Pháp)',
              exampleSentence: 'She has a clear vision for the company future.',
              category: 'Phonemes',
            ),

            // ================================================================
            // 2. Giao tiếp công sở (Workplace & Business) - 8 từ
            // ================================================================
            const PracticeItem(
              word: 'schedule',
              ipa: '/ˈskedʒuːl/',
              meaningVi: 'Lịch trình làm việc (phát âm cụm /sk/ dứt khoát)',
              exampleSentence: 'Let us check tomorrow meeting schedule.',
              category: 'Workplace',
            ),
            const PracticeItem(
              word: 'colleague',
              ipa: '/ˈkɒliːɡ/',
              meaningVi: 'Đồng nghiệp (âm cuối /ɡ/ chặn luồng hơi trong cổ)',
              exampleSentence: 'My colleague helped me finish the project.',
              category: 'Workplace',
            ),
            const PracticeItem(
              word: 'presentation',
              ipa: '/ˌpreznˈteɪʃn/',
              meaningVi: 'Bài thuyết trình (nhấn trọng âm chính vào âm tiết 3)',
              exampleSentence: 'He delivered an outstanding presentation today.',
              category: 'Workplace',
            ),
            const PracticeItem(
              word: 'negotiation',
              ipa: '/nɪˌɡəʊʃiˈeɪʃn/',
              meaningVi: 'Cuộc đàm phán hợp đồng (nhấn trọng âm 4)',
              exampleSentence: 'The salary negotiation went very smoothly.',
              category: 'Workplace',
            ),
            const PracticeItem(
              word: 'deadline',
              ipa: '/ˈdedlaɪn/',
              meaningVi: 'Hạn chót công việc (nguyên âm đôi /aɪ/ bật nhẹ /n/)',
              exampleSentence: 'The project deadline is this Friday afternoon.',
              category: 'Workplace',
            ),
            const PracticeItem(
              word: 'developer',
              ipa: '/dɪˈveləpər/',
              meaningVi: 'Lập trình viên, nhà phát triển (nhấn trọng âm 2)',
              exampleSentence: 'She is a talented mobile application developer.',
              category: 'Workplace',
            ),
            const PracticeItem(
              word: 'management',
              ipa: '/ˈmænɪdʒmənt/',
              meaningVi: 'Ban quản lý, sự quản lý (âm /dʒ/ bật rõ)',
              exampleSentence: 'Good time management is essential for success.',
              category: 'Workplace',
            ),
            const PracticeItem(
              word: 'experience',
              ipa: '/ɪkˈspɪəriəns/',
              meaningVi: 'Kinh nghiệm làm việc (nhấn trọng âm tiết 2)',
              exampleSentence: 'He has five years of mobile development experience.',
              category: 'Workplace',
            ),

            // ================================================================
            // 3. Du lịch & Khách sạn (Travel & Hospitality) - 8 từ
            // ================================================================
            const PracticeItem(
              word: 'passport',
              ipa: '/ˈpɑːspɔːt/',
              meaningVi: 'Hộ chiếu xuất nhập cảnh (âm /p/ bật hơi mạnh)',
              exampleSentence: 'Please present your passport at the immigration desk.',
              category: 'Travel',
            ),
            const PracticeItem(
              word: 'reservation',
              ipa: '/ˌrezəˈveɪʃn/',
              meaningVi: 'Sự đặt chỗ trước (nhấn trọng âm chính vào /veɪ/)',
              exampleSentence: 'I would like to confirm my hotel reservation.',
              category: 'Travel',
            ),
            const PracticeItem(
              word: 'itinerary',
              ipa: '/aɪˈtɪnərəri/',
              meaningVi: 'Lịch trình du lịch chi tiết (5 âm tiết uyển chuyển)',
              exampleSentence: 'Our travel itinerary includes Tokyo and Kyoto.',
              category: 'Travel',
            ),
            const PracticeItem(
              word: 'destination',
              ipa: '/ˌdestɪˈneɪʃn/',
              meaningVi: 'Điểm đến du lịch (chú ý âm đuôi /ʃn/)',
              exampleSentence: 'Da Nang is a popular holiday destination.',
              category: 'Travel',
            ),
            const PracticeItem(
              word: 'departure',
              ipa: '/dɪˈpɑːtʃər/',
              meaningVi: 'Giờ khởi hành (âm /tʃ/ bật dứt khoát)',
              exampleSentence: 'The flight departure has been delayed by 20 minutes.',
              category: 'Travel',
            ),
            const PracticeItem(
              word: 'luggage',
              ipa: '/ˈlʌɡɪdʒ/',
              meaningVi: 'Hành lý mang theo (âm cuối /dʒ/ bật rung)',
              exampleSentence: 'You can collect your luggage at Carousel 4.',
              category: 'Travel',
            ),
            const PracticeItem(
              word: 'boarding',
              ipa: '/ˈbɔːdɪŋ/',
              meaningVi: 'Lên máy bay / tàu (âm đuôi /ŋ/ ngân nhẹ qua mũi)',
              exampleSentence: 'Boarding will commence in approximately ten minutes.',
              category: 'Travel',
            ),
            const PracticeItem(
              word: 'restaurant',
              ipa: '/ˈrestrɒnt/',
              meaningVi: 'Nhà hàng ẩm thực (phát âm gọn 2 hoặc 3 âm tiết)',
              exampleSentence: 'We had dinner at an authentic Vietnamese restaurant.',
              category: 'Travel',
            ),

            // ================================================================
            // 4. Công nghệ & Lập trình (Technology & IT) - 8 từ
            // ================================================================
            const PracticeItem(
              word: 'artificial',
              ipa: '/ˌɑːtɪˈfɪʃl/',
              meaningVi: 'Nhân tạo (chú ý âm /ʃ/ chu môi nhẹ nhàng)',
              exampleSentence: 'Artificial intelligence is reshaping software engineering.',
              category: 'Technology',
            ),
            const PracticeItem(
              word: 'intelligence',
              ipa: '/ɪnˈtelɪdʒəns/',
              meaningVi: 'Trí tuệ, thông minh (âm /dʒ/ tròn vành dứt khoát)',
              exampleSentence: 'Human intelligence and machine learning work together.',
              category: 'Technology',
            ),
            const PracticeItem(
              word: 'algorithm',
              ipa: '/ˈælɡərɪðəm/',
              meaningVi: 'Thuật toán xử lý (âm /ð/ kẹp đầu lưỡi giữa hai hàm răng)',
              exampleSentence: 'The sorting algorithm runs in logarithmic time.',
              category: 'Technology',
            ),
            const PracticeItem(
              word: 'database',
              ipa: '/ˈdeɪtəbeɪs/',
              meaningVi: 'Cơ sở dữ liệu (chú ý âm đuôi xì nhẹ /s/)',
              exampleSentence: 'PostgreSQL is our primary relational database.',
              category: 'Technology',
            ),
            const PracticeItem(
              word: 'architecture',
              ipa: '/ˈɑːkɪtektʃər/',
              meaningVi: 'Kiến trúc hệ thống (âm /tʃər/ bật nhẹ cuối từ)',
              exampleSentence: 'Clean architecture makes the Flutter app maintainable.',
              category: 'Technology',
            ),
            const PracticeItem(
              word: 'cybersecurity',
              ipa: '/ˌsaɪbəsɪˈkjʊərəti/',
              meaningVi: 'An ninh mạng và bảo mật dữ liệu',
              exampleSentence: 'Cybersecurity is critical for cloud platforms.',
              category: 'Technology',
            ),
            const PracticeItem(
              word: 'cloud',
              ipa: '/klaʊd/',
              meaningVi: 'Điện toán đám mây (nguyên âm đôi /aʊ/ kết thúc bằng /d/)',
              exampleSentence: 'Our backend services are hosted on the cloud.',
              category: 'Technology',
            ),
            const PracticeItem(
              word: 'application',
              ipa: '/ˌæplɪˈkeɪʃn/',
              meaningVi: 'Ứng dụng phần mềm (nhấn trọng âm 3 vào /keɪ/)',
              exampleSentence: 'This mobile application supports cross-platform audio.',
              category: 'Technology',
            ),

            // ================================================================
            // 5. Mẫu câu giao tiếp thực tế (Sentences) - 6 câu
            // ================================================================
            const PracticeItem(
              word: 'practice makes perfect',
              ipa: '/ˈpræktɪs meɪks ˈpɜːfɪkt/',
              meaningVi: 'Có công mài sắt có ngày nên kim (luyện tập thường xuyên tạo nên sự hoàn hảo)',
              exampleSentence: 'Never give up speaking, practice makes perfect!',
              category: 'Sentences',
            ),
            const PracticeItem(
              word: 'nice to meet you',
              ipa: '/naɪs tuː miːt juː/',
              meaningVi: 'Rất vui được gặp bạn (câu chào xã giao kinh điển)',
              exampleSentence: 'Hello everyone, nice to meet you all today.',
              category: 'Sentences',
            ),
            const PracticeItem(
              word: 'could you repeat that',
              ipa: '/kʊd juː rɪˈpiːt ðæt/',
              meaningVi: 'Bạn có thể vui lòng nhắc lại được không (giao tiếp lịch sự)',
              exampleSentence: 'I missed that word, could you repeat that please?',
              category: 'Sentences',
            ),
            const PracticeItem(
              word: 'how can I help you',
              ipa: '/haʊ kæn aɪ help juː/',
              meaningVi: 'Tôi có thể hỗ trợ gì cho bạn (câu nói phục vụ khách hàng)',
              exampleSentence: 'Good morning, how can I help you today?',
              category: 'Sentences',
            ),
            const PracticeItem(
              word: 'speak english every day',
              ipa: '/spiːk ˈɪŋɡlɪʃ ˈevri deɪ/',
              meaningVi: 'Luyện nói tiếng Anh mỗi ngày để giữ streak kỷ luật',
              exampleSentence: 'Consistency is key: speak English every day.',
              category: 'Sentences',
            ),
            const PracticeItem(
              word: 'artificial intelligence is powerful',
              ipa: '/ˌɑːtɪˈfɪʃl ɪnˈtelɪdʒəns ɪz ˈpaʊəfl/',
              meaningVi: 'Trí tuệ nhân tạo vô cùng mạnh mẽ',
              exampleSentence: 'Artificial intelligence is powerful and helpful for learning.',
              category: 'Sentences',
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

  /// Danh sách từ vựng theo bộ lọc chủ đề
  List<PracticeItem> get _filteredList {
    if (_selectedCategory == 'All') {
      return _allPracticeList;
    }
    return _allPracticeList.where((item) => item.category == _selectedCategory).toList();
  }

  PracticeItem get _currentWord {
    final list = _filteredList;
    if (list.isEmpty) return _allPracticeList.first;
    final safeIndex = _currentIndex.clamp(0, list.length - 1);
    return list[safeIndex];
  }

  /// Đổi chủ đề học
  void _changeCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _currentIndex = 0;
      _lastPronunciationResult = null;
      _lastRecognitionResult = null;
      _isPlayingUserAudio = false;
      _playbackProgress = 0.0;
    });
  }

  /// Mở hộp thoại thêm từ vựng mới tùy chỉnh
  void _showAddCustomWordDialog() {
    final wordCtrl = TextEditingController();
    final ipaCtrl = TextEditingController();
    final meaningCtrl = TextEditingController();
    final exampleCtrl = TextEditingController();
    String newCategory = 'Phonemes';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.add_circle, color: Color(0xFFFF5722)),
                  SizedBox(width: 8),
                  Text('Thêm từ / câu mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: wordCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Từ / Câu tiếng Anh (*)',
                        hintText: 'Ví dụ: elephant, good morning...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.spellcheck),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ipaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Phiên âm IPA (Tùy chọn)',
                        hintText: 'Ví dụ: /ˈelɪfənt/',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.record_voice_over),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: meaningCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nghĩa tiếng Việt',
                        hintText: 'Ví dụ: Con voi lớn...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.translate),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: exampleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Câu ví dụ tiếng Anh',
                        hintText: 'Ví dụ: The elephant is huge.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.short_text),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: newCategory,
                      decoration: const InputDecoration(
                        labelText: 'Chủ đề',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Phonemes', child: Text('Âm vị dễ nhầm')),
                        DropdownMenuItem(value: 'Workplace', child: Text('Giao tiếp công sở')),
                        DropdownMenuItem(value: 'Travel', child: Text('Du lịch & Khách sạn')),
                        DropdownMenuItem(value: 'Technology', child: Text('Công nghệ & IT')),
                        DropdownMenuItem(value: 'Sentences', child: Text('Mẫu câu thực tế')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => newCategory = val);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final rawWord = wordCtrl.text.trim();
                    if (rawWord.isEmpty) return;

                    final newItem = PracticeItem(
                      word: rawWord,
                      ipa: ipaCtrl.text.trim().isNotEmpty ? ipaCtrl.text.trim() : '/$rawWord/',
                      meaningVi: meaningCtrl.text.trim().isNotEmpty
                          ? meaningCtrl.text.trim()
                          : 'Từ mới người học tự tạo',
                      exampleSentence: exampleCtrl.text.trim().isNotEmpty
                          ? exampleCtrl.text.trim()
                          : 'Practice saying: $rawWord',
                      category: newCategory,
                    );

                    setState(() {
                      _allPracticeList.add(newItem);
                      _selectedCategory = 'All';
                      _currentIndex = _allPracticeList.length - 1;
                      _lastPronunciationResult = null;
                      _lastRecognitionResult = null;
                      _isPlayingUserAudio = false;
                      _playbackProgress = 0.0;
                    });

                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã thêm từ "$rawWord" vào danh sách luyện tập!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722)),
                  child: const Text('Thêm vào bài tập', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
    web_audio.clearLastRecognized();
    web_audio.startWebRecording(lang: _selectedAccent);
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

    // Chờ 350ms để Web Speech Recognition hoàn tất xử lý kết quả
    await Future.delayed(const Duration(milliseconds: 350));

    String recognizedText = '';
    double confidence = 0.92;

    // Phân loại dữ liệu theo Chế độ thu âm / Kiểm thử được chọn
    if (_inputMode == 'mic') {
      recognizedText = web_audio.getLastRecognizedText();
      confidence = web_audio.getLastConfidence();
      // Nếu thời lượng ghi âm < 1 giây hoặc không có tín hiệu nói
      if (recognizedText.isEmpty && _recordingSeconds < 1) {
        recognizedText = '';
      }
    } else if (_inputMode == 'perfect') {
      recognizedText = _currentWord.word;
      confidence = 0.98;
    } else if (_inputMode == 'missed_ending') {
      // Giả lập nuốt phụ âm đuôi /s/, /t/, /z/, /d/
      final w = _currentWord.word.toLowerCase();
      if (w.endsWith('s') || w.endsWith('z') || w.endsWith('t') || w.endsWith('d')) {
        recognizedText = w.substring(0, w.length - 1);
      } else {
        recognizedText = w.length > 2 ? w.substring(0, w.length - 1) : w;
      }
      confidence = 0.88;
    } else if (_inputMode == 'wrong_vowel') {
      // Giả lập phát âm sai nguyên âm ngắn / dài
      final w = _currentWord.word.toLowerCase();
      if (w == 'sheet') {
        recognizedText = 'shit';
      } else if (w == 'sheep') {
        recognizedText = 'ship';
      } else if (w == 'cat') {
        recognizedText = 'cut';
      } else if (w.contains('ee')) {
        recognizedText = w.replaceAll('ee', 'i');
      } else if (w.contains('a')) {
        recognizedText = w.replaceFirst('a', 'u');
      } else {
        recognizedText = '${w}e';
      }
      confidence = 0.85;
    } else if (_inputMode == 'silent') {
      recognizedText = '';
      confidence = 0.0;
    }

    try {
      // Dừng thu âm và nhận diện giọng nói STT
      final result = await _speechService.stopRecordingAndRecognize(
        mockRecognizedText: recognizedText.isEmpty ? '' : recognizedText,
        mockConfidence: confidence > 0 ? confidence : 0.85,
      );

      // Phân tích và chấm điểm âm vị AI thời gian thực
      final evaluation = _phonemeEngine.analyzePronunciation(
        targetWord: _currentWord.word,
        userRecognizedText: recognizedText,
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

    // Kiểm tra xem trình duyệt có lưu được file âm thanh thật không
    final hasAudio = web_audio.hasRecordedAudio();
    if (!hasAudio && _inputMode == 'mic') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có bản ghi âm từ Micro. Hãy nhấn vào biểu tượng Micro để ghi âm giọng nói!'),
          duration: Duration(seconds: 2),
        ),
      );
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
    if (_currentIndex < _filteredList.length - 1) {
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
    final currentList = _filteredList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Luyện Phát Âm Tiếng Anh AI'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Nút thêm từ mới tùy chọn
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFF5722)),
            tooltip: 'Thêm từ / câu mới',
            onPressed: _showAddCustomWordDialog,
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================================================================
            // 1. THANH CHỌN CHỦ ĐỀ LUYỆN TẬP (CATEGORY FILTER BAR)
            // ================================================================
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('All', 'Tất cả (${_allPracticeList.length})'),
                  const SizedBox(width: 6),
                  _buildCategoryChip('Phonemes', '🔤 Âm vị dễ nhầm (10)'),
                  const SizedBox(width: 6),
                  _buildCategoryChip('Workplace', '💼 Công sở (8)'),
                  const SizedBox(width: 6),
                  _buildCategoryChip('Travel', '✈️ Du lịch (8)'),
                  const SizedBox(width: 6),
                  _buildCategoryChip('Technology', '💻 Công nghệ (8)'),
                  const SizedBox(width: 6),
                  _buildCategoryChip('Sentences', '🗣️ Mẫu câu (6)'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ================================================================
            // 2. BỘ ĐIỀU KHIỂN CHẾ ĐỘ KIỂM THỬ AI (SIMULATION / MIC CONTROLLER)
            // ================================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, size: 18, color: Colors.amber.shade900),
                  const SizedBox(width: 8),
                  Text(
                    'Đầu vào:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _inputMode,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'mic',
                            child: Text('🎙️ Micro thật (Web STT) - Tự động chấm theo giọng nói'),
                          ),
                          DropdownMenuItem(
                            value: 'perfect',
                            child: Text('🎯 Giả lập: Phát âm chuẩn (95-100 điểm)'),
                          ),
                          DropdownMenuItem(
                            value: 'missed_ending',
                            child: Text('⚠️ Giả lập: Bỏ sót âm đuôi /s/, /t/, /z/ (70-75 điểm)'),
                          ),
                          DropdownMenuItem(
                            value: 'wrong_vowel',
                            child: Text('🔀 Giả lập: Sai nguyên âm ngắn/dài (55-65 điểm)'),
                          ),
                          DropdownMenuItem(
                            value: 'silent',
                            child: Text('🔇 Giả lập: Không nói gì / Im lặng (0 điểm)'),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            setState(() => _inputMode = mode);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

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
                  'Từ ${_currentIndex + 1} / ${currentList.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                IconButton(
                  onPressed: _currentIndex < currentList.length - 1 ? _nextWord : null,
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
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      _currentWord.word,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _currentWord.word.length > 15 ? 24 : 34,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.1,
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
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _currentWord.meaningVi,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${_currentWord.exampleSentence}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.blueGrey.shade600,
                      ),
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
            const SizedBox(height: 16),

            // Bộ hiển thị sóng âm thời gian thực Waveform Visualizer
            WaveformVisualizerWidget(
              isRecording: _isRecording,
              isPlaying: _isPlayingUserAudio,
              amplitudeStream: _speechService.amplitudeStream,
              playbackProgress: _playbackProgress,
              height: 80,
            ),
            const SizedBox(height: 18),

            // Nút bấm Microphone thu âm lớn ở trung tâm
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isProcessingAI ? null : _toggleRecording,
                    child: ScaleTransition(
                      scale: _isRecording ? _micPulseAnimation : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: 80,
                        height: 80,
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
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isRecording
                        ? 'Đang thu âm: 00:0${_recordingSeconds}s (Nhấn để dừng)'
                        : _isProcessingAI
                            ? 'AI đang phân tích âm vị...'
                            : 'Chạm vào Micro để bắt đầu luyện nói',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isRecording ? Colors.redAccent : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                        size: 36,
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
                                _lastRecognitionResult!.recognizedText.isEmpty
                                    ? 'STT: (Không có âm thanh)'
                                    : 'STT: "${_lastRecognitionResult!.recognizedText}"',
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

  Widget _buildCategoryChip(String categoryKey, String label) {
    final isSelected = _selectedCategory == categoryKey;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selectedColor: primaryColor,
      backgroundColor: Colors.grey.shade200,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      onSelected: (_) => _changeCategory(categoryKey),
    );
  }
}
