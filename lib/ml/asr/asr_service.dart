/// Voice note → text. Owner: C. Task: T-29 (L2, Sun 02:30–04:00 per
/// docs/Work Flow.md §6).
///
/// Primary path: whisper.cpp binding, tiny model, 45-minute timebox.
/// Fallback: `speech_to_text` with the Android offline language pack. Be
/// honest on stage — tiny handles English/Hinglish; Tamil is roadmap (see
/// docs/00_START_HERE.md open question #5).
library;

import '../../core/failures.dart';
import '../../core/result.dart';

abstract class AsrService {
  Future<Result<void, Failure>> load();
  Future<Result<String, Failure>> transcribe(String audioFilePath);
}
