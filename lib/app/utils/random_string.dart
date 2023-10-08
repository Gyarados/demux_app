import 'dart:math';

String randomString(int length) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Random random = Random();

  return String.fromCharCodes(
    Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))),
  );
}
