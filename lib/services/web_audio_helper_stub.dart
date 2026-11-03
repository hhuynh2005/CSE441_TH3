/// Stub implementation for non-web platforms (e.g. Unit tests, Android VM)
void speakWord(String text, {String lang = 'US'}) {}

void startWebRecording({String lang = 'US'}) {}

void stopWebRecording() {}

void playRecordedAudio() {}

void stopRecordedAudio() {}

String getLastRecognizedText() => '';

double getLastConfidence() => 0.0;

bool hasRecordedAudio() => false;

void clearLastRecognized() {}
