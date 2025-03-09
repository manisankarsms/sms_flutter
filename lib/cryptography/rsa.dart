import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypts;
import 'package:pointycastle/asymmetric/api.dart';

class RSAUtil {
  static late encrypts.RSAKeyParser keyParser;
  static late encrypts.Encrypter encrypter;

  static void init(String publicKeyPem, String privateKeyPem) {
    final publicKey = encrypts.RSAKeyParser().parse(publicKeyPem) as RSAPublicKey;
    final privateKey = encrypts.RSAKeyParser().parse(privateKeyPem) as RSAPrivateKey;
    encrypter = encrypts.Encrypter(encrypts.RSA(publicKey: publicKey, privateKey: privateKey));
  }

  static String encrypt(String plainText) {
    return encrypter.encrypt(plainText).base64;
  }

  static String decrypt(String encryptedText) {
    return encrypter.decrypt64(encryptedText);
  }
}
