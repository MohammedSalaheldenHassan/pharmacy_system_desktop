import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// SHA-256 + per-user random salt. Good enough for a local offline
/// desktop app; if this ever needs to resist large-scale offline
/// cracking, swap for a slow KDF (bcrypt/scrypt/argon2) instead —
/// contained entirely to this file and [EmployeeRepository].
class PasswordHasher {
  PasswordHasher._();

  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  static bool verify(String password, String salt, String expectedHash) {
    return hash(password, salt) == expectedHash;
  }
}
