import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:math';
import 'package:encryption/salt_password.dart' as salter;

final _times = pow(2, 16);
final Hash _hasher = sha256;

Future<Digest> decrypt(String _salt, String _password) async{
  var salted = salter.saltPassword(_salt, _password);
  var _encrypted = _hasher.convert(utf8.encode(salted));

  for (var i = 0; i < _times; i++) {
    salted = salter.saltPassword(_salt, _encrypted.toString());
    if (checkSaltedCorrect(salted, _salt)) {
      _encrypted = _hasher.convert(utf8.encode(salted));
    }
  }

  exitCode = 0;
  return _encrypted;
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _random = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_random.nextInt(_chars.length))));

bool checkSaltedCorrect(String salted, String salt) {
  for (var i = 0; i < salt.length; i++) {
    if (!salted.contains(salt[i])) {
      exitCode = 2;
      return false;
    }
  }
  exitCode = 0;
  return true;
}