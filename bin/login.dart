import 'dart:io';
import 'package:encryption/decrypt.dart' as decrypt;
import 'package:encryption/default_path.dart' as env;

var _inputName = '';
final _process = 'sqlite3';
final _usersDb = '${env.usersPath}/${env.usersDb}';

void main() async{
  var _uniqueName = false;

  while(_uniqueName == false) {
    stdout.write('Username: ');
    _inputName = stdin.readLineSync();
    if (_validateName(_inputName)) {
      if (await _userRegistered(_inputName)) {
        _uniqueName = true;
      } else {
        print('Username not registered.');
      }
    } else {
      print('Invalid Username');
    }
  }

  final _username = _inputName;
  var _count = 0;
  var _validPassword = false;

  while (_validPassword == false) {
    stdout.write('Password: ');
    stdin.echoMode = false;
    var _input = stdin.readLineSync();
    print('*' * _input.length);
    print('Checking login credentials...');
    if (_input.length < 8) {
      print('Attention! Password should be at least 8 characters long!');
    } else {
      _count++;
      final _password = _input;
      final _userSalt = await _getSalt(_username);
      var _encrypted = await decrypt.decrypt(_userSalt, _password);
      if(await _verifyAttempt('$_encrypted', _username)){
        print('Logged in Successfully!');
        _validPassword = true;
      } else {
        print('Wrong password!');
        if (_count > 3) { // Could make something to block more attempts for a few minutes. Need to learn.
          print('Too many wrong attempts, come back later!');
          exitCode == 2;
          break;
        }
      }
    }
  }
}

Future _getSalt(String _username) async {
  final _query = 'SELECT salt FROM users WHERE username = "$_username"';
  var _result = await Process.run(_process, [_usersDb, _query]);

  return _result.stdout.toString().replaceAll('\n', '');
}

Future<bool> _verifyAttempt(String _encrypted, String _username) async{
  final _id = await _getUserId(_username);
  final _hashesDb = '${env.hashesPath}/${env.hashesDb}';
  final _query = 'SELECT hash FROM hashes WHERE id = $_id';
  var _result = await Process.run(_process, [_hashesDb, _query]);
  var _compare = _result.stdout.toString().replaceAll('\n', '');

  return _encrypted == _compare;
}

Future<bool> _userRegistered(String _username) async {
  final _query = 'SELECT EXISTS(SELECT 1 FROM users WHERE username = "$_username" LIMIT 1)';
  final _result =
  await Process.run(_process, [_usersDb, _query]);
  if (int.parse(_result.stdout) == 0) {
    return false;
  }
  return true;
}

bool _validateName(String _userName) {
  // var _alpha = RegExp(r'^[a-zA-Z0-9]+$'); // For reference
  return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_userName);
}

Future<int> _getUserId(String _username) async {
  final _query = 'SELECT id FROM users WHERE username = "$_username"';
  var _result = await Process.run(_process, [_usersDb, _query]);

  return int.parse(_result.stdout);
}