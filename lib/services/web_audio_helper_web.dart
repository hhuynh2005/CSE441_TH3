// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;

/// Web implementation calling browser JavaScript APIs
void speakWord(String text, {String lang = 'US'}) {
  try {
    js.context.callMethod('speakWord', [text, lang]);
  } catch (e) {
    // Fallback if JS error
  }
}

void startWebRecording({String lang = 'US'}) {
  try {
    js.context.callMethod('startWebRecording', [lang]);
  } catch (e) {
    // Fallback if JS error
  }
}

void stopWebRecording() {
  try {
    js.context.callMethod('stopWebRecording');
  } catch (e) {
    // Fallback if JS error
  }
}

void playRecordedAudio() {
  try {
    js.context.callMethod('playRecordedAudio');
  } catch (e) {
    // Fallback if JS error
  }
}

void stopRecordedAudio() {
  try {
    js.context.callMethod('stopRecordedAudio');
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
