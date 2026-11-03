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

void startWebRecording() {
  try {
    js.context.callMethod('startWebRecording');
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
