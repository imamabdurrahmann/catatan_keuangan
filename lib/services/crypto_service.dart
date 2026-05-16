import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

/// AES-256-CBC encryption for export file protection.
/// Uses PBKDF2 key derivation from the password and a random IV per encryption.
class CryptoService {
  static const _keyLength = 32; // 256 bits
  static const _ivLength = 16; // 128 bits
  static const _iterations = 10000;

  /// Encrypts [json] data using AES-256-CBC with a password.
  /// Returns a string prefixed with "ENCRYPTED:" containing Base64-encoded salt + IV + ciphertext.
  static String encryptData(String json, String password) {
    if (password.isEmpty) return json;

    // Generate random salt and IV
    final random = Random.secure();
    final salt = Uint8List(16);
    for (var i = 0; i < salt.length; i++) {
      salt[i] = random.nextInt(256);
    }
    final ivBytes = Uint8List(_ivLength);
    for (var i = 0; i < ivBytes.length; i++) {
      ivBytes[i] = random.nextInt(256);
    }
    final iv = encrypt.IV(ivBytes);

    // Derive key from password using PBKDF2
    final key = _pbkdf2(password, salt);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(json, iv: iv);

    // Combine salt + iv + ciphertext, then Base64 encode
    final combined = Uint8List(
      salt.length + ivBytes.length + encrypted.bytes.length,
    );
    combined.setRange(0, salt.length, salt);
    combined.setRange(salt.length, salt.length + ivBytes.length, ivBytes);
    combined.setRange(
      salt.length + ivBytes.length,
      combined.length,
      encrypted.bytes,
    );

    return 'ENCRYPTED:${base64Encode(combined)}';
  }

  /// Decrypts [encrypted] data using a password.
  /// If [encrypted] does not start with "ENCRYPTED:", returns it as-is (not encrypted).
  /// Throws [FormatException] if decryption fails (wrong password or corrupted data).
  static String decryptData(String encrypted, String password) {
    if (password.isEmpty) return encrypted;
    if (!encrypted.startsWith('ENCRYPTED:')) return encrypted;

    try {
      final combined = base64Decode(encrypted.substring('ENCRYPTED:'.length));

      // Split salt (16) + iv (16) + ciphertext
      final salt = combined.sublist(0, 16);
      final ivBytes = combined.sublist(16, 16 + _ivLength);
      final cipherBytes = combined.sublist(16 + _ivLength);

      final key = _pbkdf2(password, salt);
      final iv = encrypt.IV(ivBytes);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.cbc),
      );

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(cipherBytes),
        iv: iv,
      );
      return decrypted;
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException('Dekripsi gagal: $e');
    }
  }

  /// Returns true if [content] appears to be encrypted.
  static bool isEncrypted(String content) {
    return content.startsWith('ENCRYPTED:');
  }

  /// Derives a 256-bit AES key from a password using PBKDF2-HMAC-SHA256.
  static Uint8List _pbkdf2(String password, Uint8List salt) {
    final params = Pbkdf2Parameters(salt, _iterations, _keyLength);
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(params);

    final passwordBytes = utf8.encode(password);
    return derivator.process(Uint8List.fromList(passwordBytes));
  }
}
