class ValueOutput<T> {
  ValueOutput(this.value);
  final T value;
}

class ErrorOutput<T> {
  ErrorOutput(this.error);
  final Object error;
}

class EmptyOutput<T> {}

class Outputs {
  static ValueOutput<T> value<T>(T value) => ValueOutput<T>(value);
  static ErrorOutput<T> error<T>(Object error) => ErrorOutput<T>(error);
  static EmptyOutput<T> empty<T>() => EmptyOutput<T>();
}

class GuardRejectedError implements Exception {
  GuardRejectedError(this.message);
  final String message;
  @override
  String toString() => message;
}

class UseCase<P, R> {
  UseCase({
    required this.execute,
    this.guard,
  });

  final R Function(P param) execute;
  final void Function(P param)? guard;

  Object process(P param) {
    try {
      guard?.call(param);
      return Outputs.value(execute(param));
    } catch (error) {
      return Outputs.error<R>(error);
    }
  }
}

class ChainUseCase<P, I, R> {
  ChainUseCase({
    required this.first,
    required this.second,
  });

  final UseCase<P, I> first;
  final R Function(I result, P param) second;

  Object process(P param) {
    final firstOutput = first.process(param);
    if (firstOutput is ValueOutput<I>) {
      try {
        return Outputs.value(second(firstOutput.value, param));
      } catch (error) {
        return Outputs.error<R>(error);
      }
    }
    if (firstOutput is ErrorOutput<I>) {
      return Outputs.error<R>(firstOutput.error);
    }
    return Outputs.empty<R>();
  }
}

class SequenceUseCase<P, R> {
  SequenceUseCase({required this.step});

  final R Function(P param) step;

  Object process(List<P> values) {
    if (values.isEmpty) {
      return Outputs.empty<List<R>>();
    }

    try {
      return Outputs.value(values.map(step).toList());
    } catch (error) {
      return Outputs.error<List<R>>(error);
    }
  }
}

class UseCaseDispatcher {
  Object dispatch<P, R>(P param, UseCase<P, R> useCase, {void Function(Object output)? publish}) {
    final output = useCase.process(param);
    publish?.call(output);
    return output;
  }
}
