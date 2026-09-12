/// On-device LLM — structured visit record + reorder rationale. Owner: C.
/// Task IDs: T-23 (bundle Gemma 3 1B int4 via flutter_gemma, 90-minute
/// timebox — if it won't load, hard-switch to a llama.cpp binding +
/// Qwen2.5-1.5B-Instruct Q4_K_M, per the risk register in
/// docs/Work Flow.md §9), T-26 (on-device prompt engineering).
///
/// Hard rule (docs/00_START_HERE.md, non-negotiable #3): the LLM is never in
/// the blocking path. Detection → diff → order draft must work perfectly
/// with the LLM disabled. Force JSON output, write a tolerant parser, and a
/// deterministic non-LLM fallback for every field this produces.
library;

import '../../core/failures.dart';
import '../../core/result.dart';

class VisitRecord {
  const VisitRecord({required this.summaryProse, required this.reorderRationale});
  final String summaryProse;
  final String reorderRationale;
}

abstract class LlmService {
  Future<Result<void, Failure>> load();

  /// [voiceTranscript] and [shelfContext] are plain strings — build the
  /// prompt from deterministic data, never let the LLM see raw DB rows.
  Future<Result<VisitRecord, Failure>> generateVisitRecord({
    required String voiceTranscript,
    required String shelfContext,
  });
}
