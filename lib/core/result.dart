/// Lightweight Result type — every service returns this instead of throwing.
/// Pattern: `switch (result) { case Ok(:final value) => ..., case Err(:final failure) => ... }`
sealed class Result<T, F> {
  const Result();
}

final class Ok<T, F> extends Result<T, F> {
  const Ok(this.value);
  final T value;
}

final class Err<T, F> extends Result<T, F> {
  const Err(this.failure);
  final F failure;
}

extension ResultX<T, F> on Result<T, F> {
  bool get isOk => this is Ok<T, F>;
  bool get isErr => this is Err<T, F>;

  T get valueOrThrow => switch (this) {
        Ok(:final value) => value,
        Err(:final failure) => throw StateError('Result is Err: $failure'),
      };

  T? get valueOrNull => switch (this) {
        Ok(:final value) => value,
        Err() => null,
      };

  F? get failureOrNull => switch (this) {
        Ok() => null,
        Err(:final failure) => failure,
      };

  Result<U, F> map<U>(U Function(T) fn) => switch (this) {
        Ok(:final value) => Ok(fn(value)),
        Err(:final failure) => Err(failure),
      };
}
