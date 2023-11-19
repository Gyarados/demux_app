import 'package:uuid/uuid.dart';

class UUIDGenerator {
  static const _uuid = Uuid();

  // Static method to generate a v4 UUID
  static String generateV4() {
    return _uuid.v4();
  }

  // Alternatively, you can use a static getter
  static String get newUUID => _uuid.v4();
}
