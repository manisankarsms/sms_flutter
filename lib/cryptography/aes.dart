import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:encrypt/encrypt.dart';

class AESUtil {
  /// Fixed IV (16 bytes) – Not recommended for high security
  static const String _ivString = '0123456789abcdef'; // 16 bytes
  static final IV iv = IV.fromUtf8(_ivString);

  /// Generates a secure random 32-byte AES key (AES-256)
  static String generateKey() {
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(Uint8List.fromList(keyBytes)); // Base64-encoded key
  }

  /// Encrypts text using AES-256-CBC
  static String encrypt(String plainText, String base64Key) {
    final key = Key.fromBase64(base64Key);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64; // Return only the ciphertext
  }

  /// Decrypts text using AES-256-CBC
  static String decrypt(String encryptedText, String base64Key) {
    final key = Key.fromBase64(base64Key);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    return encrypter.decrypt64(encryptedText, iv: iv);
  }
}
