import 'package:dart_ode/dart_ode.dart';
import 'package:test/test.dart';

void main() {
  test('direct use case builds a spotlight', () {
    final useCase = UseCase<String, String>(execute: (param) => 'spotlight:$param');
    final output = useCase.process('pikachu');
    expect(output, isA<ValueOutput<String>>());
  });

  test('chain use case keeps comparison narrative', () {
    final chain = ChainUseCase<String, String, String>(
      first: UseCase<String, String>(execute: (param) => 'bulbasaur'),
      second: (result, param) => '$result vs ivysaur',
    );

    final output = chain.process('ignored');
    expect(output, isA<ValueOutput<String>>());
  });

  test('sequence use case preserves ordered values', () {
    final sequence = SequenceUseCase<String, String>(step: (param) => param);
    final output = sequence.process(['bulbasaur', 'charmander', 'squirtle']);
    expect(output, isA<ValueOutput<List<String>>>());
  });

  test('guard rejects invalid dispatch', () {
    final guarded = UseCase<List<String>, String>(
      guard: (param) {
        if (param.first == param.last) {
          throw GuardRejectedError('comparison requires distinct entries');
        }
      },
      execute: (param) => '${param.first} vs ${param.last}',
    );

    final output = guarded.process(['pikachu', 'pikachu']);
    expect(output, isA<ErrorOutput<String>>());
  });
}
