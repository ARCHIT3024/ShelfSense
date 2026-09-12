/// Domain failure types. Every service uses `Result<T, Failure>`.
/// No exceptions cross a service boundary.
sealed class Failure {
  const Failure(this.message);
  final String message;
  @override
  String toString() => '$runtimeType($message)';
}

// --- ML failures -------------------------------------------------------
final class DetectorNotLoaded extends Failure {
  const DetectorNotLoaded() : super('Detector model not loaded');
}

final class DetectorInferenceFailed extends Failure {
  const DetectorInferenceFailed(super.message);
}

final class EmbedderNotLoaded extends Failure {
  const EmbedderNotLoaded() : super('Embedder model not loaded');
}

final class EmbedderInferenceFailed extends Failure {
  const EmbedderInferenceFailed(super.message);
}

final class OcrFailed extends Failure {
  const OcrFailed(super.message);
}

final class AsrFailed extends Failure {
  const AsrFailed(super.message);
}

final class LlmNotLoaded extends Failure {
  const LlmNotLoaded() : super('LLM not loaded');
}

final class LlmGenerationFailed extends Failure {
  const LlmGenerationFailed(super.message);
}

// --- DB / storage failures ---------------------------------------------
final class DbFailure extends Failure {
  const DbFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

final class NotFound extends Failure {
  const NotFound(super.message);
}

// --- Export failures ---------------------------------------------------
final class ExportFailed extends Failure {
  const ExportFailed(super.message);
}

final class InsufficientStorage extends Failure {
  const InsufficientStorage() : super('Not enough space — free up and retry');
}

// --- Permission failures -----------------------------------------------
final class PermissionDenied extends Failure {
  const PermissionDenied(super.message);
}

// --- Camera failures ---------------------------------------------------
final class CameraFailure extends Failure {
  const CameraFailure(super.message);
}
