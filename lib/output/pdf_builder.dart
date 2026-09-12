/// Route summary PDF — Owner: C. Task: T-29 (L2), depends on
/// lib/ml/llm/llm_service.dart's VisitRecord output.
///
/// Pure-Dart `pdf` + `printing` packages, rendered entirely on the handset.
/// Not started — wire this up once the LLM's structured visit record is
/// producing real output (no point formatting a PDF around a stub).
library;

import '../core/failures.dart';
import '../core/result.dart';

abstract class PdfBuilder {
  Future<Result<String, Failure>> buildBeatSummaryPdf({
    required String beatName,
    required List<String> visitSummaries,
  });
}
