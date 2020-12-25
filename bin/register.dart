import 'dart:io';
import 'package:encryption/encrypt.dart' as encrypt;
import 'package:encryption/default_path.dart' as env;

var _inputName = '';
final _process = 'sqlite3';
final _usersDb = '${env.usersPath}/${env.usersDb}';
final _hashesDb = '${env.hashesPath}/${env.hashesDb}';

void main() async {
  await _createUsersTable();
  await _createHashesTable();
  var _validInput = false;
  while (_validInput == false) {
    stdout.write('Username: ');
    _inputName = stdin.readLineSync();
    if (await _checkUserExist(_inputName)) {
      print('Username not available!');
    } else if (_inputName.isEmpty) {
      print('Empty username not allowed');
    } else if (_validateName(_inputName)) {
      _validInput = true;
    } else {
      print(
          'Username should contain only Letters and Numbers, without empty space');
    }
  }

  _validInput = false;
  final _userName = _inputName;

  while (_validInput == false) {
    stdin.echoMode = false;
    stdout.write('Password: ');
    var _input = stdin.readLineSync();
    print('*' * _input.length);
    if (_input.length < 8) {
      print('Your Password should be at least 8 characters long!');
    } else {
      stdout.write('Enter Password again: ');
      var _confirmInput = stdin.readLineSync();
      print('*' * _confirmInput.length);
      if (_confirmInput != _input) {
        print('Password entered do not match, please try again.');
      } else {
        final _password = _input;
        var _encrypted = await encrypt.encrypt(_userName, _password);
        var dateNow = _getDate();

        if (exitCode == 0) {
          await _saveUserInfo(_userName, dateNow[0],
              '${dateNow[1]} ${dateNow[2]}', _encrypted[1]);
          final lastId = await _getLastId();
          await _saveUserHash('${_encrypted[0]}', lastId);
          print('$_userName registered successfully!');
          _validInput = true;
        } else {
          print('Something went wrong, please try again later');
          break;
        }
      }
    }
  }
}

// Create table for users information
Future<void> _createUsersTable() async {
  await Directory(env.usersPath).create(recursive: true);

  final _query =
      'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT NOT NULL, date TEXT NOT NULL, time TEXT NOT NULL, salt TEXT NOT NULL)';
  await Process.run(_process, [_usersDb, _query]);
}

// Create table to store hash value of respective user
Future<void> _createHashesTable() async {
  await Directory(env.hashesPath).create(recursive: true);

  final _query =
      'CREATE TABLE IF NOT EXISTS hashes (id INTEGER PRIMARY KEY, hash TEXT NOT NULL)';
  await Process.run(_process, [_hashesDb, _query]);
}

Future<bool> _checkUserExist(String _userInput) async {
  final _query = 'SELECT username FROM users WHERE username = "$_userInput"';
  final _username =
      await Process.run(_process, [_usersDb, _query]);

  _username.stderr.toString().isNotEmpty ? exitCode = 1 : null;

  return _userInput == _username.stdout.toString().replaceAll('\n', '');
}

bool _validateName(String _userName) {
  // var _alpha = RegExp(r'^[a-zA-Z0-9]+$'); // For reference
  return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_userName);
}

Future<void> _saveUserInfo(
    String userName, String date, String time, String salt) async {
  final _query =
      'INSERT INTO users (username, date, time, salt) VALUES("$userName", "$date", "$time", "$salt")';
  await Process.run(_process, [_usersDb, _query]);
}

Future<void> _saveUserHash(String _hash, int _id) async {
  final _query = 'INSERT INTO hashes (id, hash) VALUES($_id, "$_hash")';
  await Process.run(_process, [_hashesDb, _query]);
}

Future<int> _getLastId() async {
  final _query = 'SELECT id FROM users ORDER BY id DESC LIMIT 1';
  var last = await Process.run(_process, [_usersDb, _query]);

  return int.parse(last.stdout.toString());
}

List _getDate() {
  var currentTime = DateTime.now();
  var year = currentTime.year;
  var month = currentTime.month;
  var day = currentTime.day;
  var hour = currentTime.hour;
  var minute = currentTime.minute;
  var second = currentTime.second;

  var currentDate =
      "${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  var currentHour = "${hour.toString().padLeft(2, '0')}"
      ":${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}";

  return [currentDate, currentHour, '${hour > 11 ? 'PM' : 'AM'}'];
}
