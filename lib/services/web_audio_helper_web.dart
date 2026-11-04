// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js' as js;

html.AudioElement? _nativeAudioElement;

/// Khởi tạo và gắn Audio Player cố định vào DOM để tránh Chrome Autoplay throttling
html.AudioElement _getNativeAudioPlayer() {
  if (_nativeAudioElement == null) {
    final existing = html.document.getElementById('speakup_native_player');
    if (existing is html.AudioElement) {
      _nativeAudioElement = existing;
    } else {
      final audio = html.AudioElement()
        ..id = 'speakup_native_player'
        ..style.display = 'none';
      html.document.body?.append(audio);
      _nativeAudioElement = audio;
    }
  }
  return _nativeAudioElement!;
}

void _playChime({double freq = 520.0, double durationSeconds = 0.12}) {
  try {
    js.context.callMethod('playChime', [freq, durationSeconds]);
  } catch (_) {}
}

/// Phát âm thanh mẫu chuẩn người bản xứ (Đa nguồn: Web Audio + Google TTS + Youdao CDN + Web Speech API)
void speakWord(String text, {String lang = 'US'}) {
  final cleanText = text.trim();
  if (cleanText.isEmpty) return;

  // Hiệu ứng âm thanh khi bấm nút
  _playChime(freq: 587.33, durationSeconds: 0.10);

  try {
    // 1. Đánh thức Web Speech Synthesis nếu bị paused
    if (html.window.speechSynthesis != null) {
      html.window.speechSynthesis!.resume();
    }

    final encoded = Uri.encodeComponent(cleanText);
    final accentType = (lang == 'UK') ? '1' : '2';

    // Thử 1: Google TTS Engine chuẩn
    final googleUrl = 'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&tl=en&q=$encoded';
    // Thử 2: Youdao Human Pronunciation CDN
    final youdaoUrl = 'https://dict.youdao.com/dictvoice?audio=$encoded&type=$accentType';

    final player = _getNativeAudioPlayer();
    player.src = googleUrl;

    bool played = false;
    void fallbackToTTS() {
      if (played) return;
      played = true;
      try {
        if (html.window.speechSynthesis != null) {
          html.window.speechSynthesis!.cancel();
          html.window.speechSynthesis!.resume();
          final utterance = html.SpeechSynthesisUtterance(cleanText);
          utterance.lang = (lang == 'UK') ? 'en-GB' : 'en-US';
          utterance.rate = 0.85;
          utterance.pitch = 1.0;
          html.window.speechSynthesis!.speak(utterance);
        }
      } catch (e) {
        // Fallback error
      }
    }

    player.onError.first.then((_) {
      // Nếu Google TTS gặp lỗi, thử Youdao CDN
      player.src = youdaoUrl;
      player.play().catchError((_) {
        fallbackToTTS();
      });
    });

    player.play().then((_) {
      played = true;
    }).catchError((err) {
      // Nếu Chrome autoplay policy chặn audio, fallback ngay sang TTS hoặc gọi qua JS
      fallbackToTTS();
      try {
        js.context.callMethod('speakWord', [cleanText, lang]);
      } catch (_) {}
    });
  } catch (e) {
    try {
      js.context.callMethod('speakWord', [cleanText, lang]);
    } catch (_) {}
  }
}

void startWebRecording({String lang = 'US'}) {
  _playChime(freq: 440.0, durationSeconds: 0.08);
  try {
    js.context.callMethod('startWebRecording', [lang]);
  } catch (e) {
    // Fallback if JS error
  }
}

void stopWebRecording() {
  _playChime(freq: 330.0, durationSeconds: 0.08);
  try {
    js.context.callMethod('stopWebRecording');
  } catch (e) {
    // Fallback if JS error
  }
}

void playRecordedAudio() {
  _playChime(freq: 523.25, durationSeconds: 0.12);

  // 1. Thử phát từ JavaScript blob URL (bản ghi micro thực tế)
  try {
    js.context.callMethod('playRecordedAudio');
  } catch (e) {
    // Fallback
  }

  // 2. Dự phòng: Nếu không có file blob thực tế (ví dụ mic bị tắt hoặc chạy giả lập)
  // Đọc lại từ vựng vừa nhận dạng bằng giọng học viên để đảm bảo luôn phát ra âm thanh
  final lastText = getLastRecognizedText();
  if (lastText.isNotEmpty && !hasRecordedAudio()) {
    try {
      if (html.window.speechSynthesis != null) {
        html.window.speechSynthesis!.cancel();
        html.window.speechSynthesis!.resume();
        final utterance = html.SpeechSynthesisUtterance(lastText);
        utterance.lang = 'en-US';
        utterance.rate = 0.90;
        utterance.pitch = 0.85; // Giọng người học trầm ấm
        html.window.speechSynthesis!.speak(utterance);
      }
    } catch (_) {}
  }
}

void stopRecordedAudio() {
  try {
    js.context.callMethod('stopRecordedAudio');
    if (html.window.speechSynthesis != null) {
      html.window.speechSynthesis!.cancel();
    }
  } catch (e) {
    // Fallback if JS error
  }
}

String getLastRecognizedText() {
  try {
    final res = js.context.callMethod('getLastRecognizedText');
    return res?.toString().trim().toLowerCase() ?? '';
  } catch (e) {
    return '';
  }
}

double getLastConfidence() {
  try {
    final conf = js.context.callMethod('getLastConfidence');
    if (conf is num) return conf.toDouble();
    return 0.0;
  } catch (e) {
    return 0.0;
  }
}

bool hasRecordedAudio() {
  try {
    final res = js.context.callMethod('hasRecordedAudio');
    return res == true;
  } catch (e) {
    return false;
  }
}

void clearLastRecognized() {
  try {
    js.context.callMethod('clearLastRecognized');
  } catch (e) {
    // Fallback
  }
}
