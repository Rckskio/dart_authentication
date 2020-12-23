import'dart:io';
import 'dart:convert';
import 'dart:cli';
import 'package:encryption/encrypt.dart' as encrypt;
import 'package:encryption/default_path.dart' as _default_path;

var _inputName = '';

Future<void> main() async{
  var _correctInput = false;
  while(_correctInput == false) {
    stdout.write('Username: ');
    _inputName = stdin.readLineSync();
    if (_checkFileExist(_inputName)) {
      print('Username not available!');
    } else if (_inputName.isEmpty){
      print('Empty username not allowed');
    } else if(_validateName(_inputName)){
      _correctInput = true;
    } else {
      print('Username should contain only Letters and Numbers, without empty space');
    }
  }

  _correctInput = false;
  final _userName = _inputName;
  while (_correctInput == false) {
    stdout.write('Password: ');
    var _input = _readHidden();
    if (_input.length < 8) {
      print('Attention! Password should be at least 8 characters long!');
    } else {
      final _password = _input;
      var _encrypted = await encrypt.encrypt(_userName, _password);
      var dateNow = _getDate();
      await saveUserInfo(_userName, dateNow[0], dateNow[1], _encrypted[1]);
      var lastId = await getLastId();
      await saveUserHash('${_encrypted[0]}', lastId);

      print('$_userName registered successfully!');
      exitCode = 0;
      exit(exitCode);

    }
  }
}

// Function created by Brett Sutton from the project dcli https://github.com/bsutton/dcli/tree/0.34.6-linux
// Extracted from lib/src/functions/ask.dart and no changes were made.
String _readHidden() {
  const _backspace = 127;
  const _space = 32;
  const _ = 8;
  var _value = <int>[];

  try {
    stdin.echoMode = false;
    stdin.lineMode = false;
    int _char;
    do {
      _char = stdin.readByteSync();
      if (_char != 10) {
        if (_char == _backspace) {
          if (_value.isNotEmpty) {
            // move back a character,
            // print a space an move back again.
            // required to clear the current character
            // move back one space.
            stdout.writeCharCode(_);
            stdout.writeCharCode(_space);
            stdout.writeCharCode(_);
            _value.removeLast();
          }
        } else {
          stdout.write('*');
          // we must wait for flush as only one flush can be outstanding at a time.
          waitFor<void>(stdout.flush());
          _value.add(_char);
        }
      }
    } while (_char != 10);
  } finally {
    stdin.echoMode = true;
    stdin.lineMode = true;
  }

  // output a newline as we have suppressed it.
  print('');

  // return the entered value as a String.
  return Encoding.getByName('utf-8').decode(_value);
}

bool _checkFileExist(String _userName) {
  return File(_default_path.path + _userName).existsSync() && _userName.isNotEmpty;
}

List _getDate() {
  var today = DateTime.now();
  var year = today.year;
  var month = today.month;
  var day = today.day;
  var hour = today.hour;
  var minute = today.minute;
  var second = today.second;

  var currentDate ="${year.toString()}-${month.toString().padLeft(2,'0')}-${day.toString().padLeft(2,'0')}";
  var currentTime = "${hour.toString().padLeft(2,'0')}"
      ":${minute.toString().padLeft(2,'0')}:${second.toString().padLeft(2,'0')}";

  // previously made, same result of current return statement.
  // var date = [];
  // date.add(currentDate);
  // date.add('$currentTime ${hour > 11 ? 'PM' : 'AM'}');

  exitCode = 0;
  return [currentDate, currentTime, '${hour > 11 ? 'PM' : 'AM'}'];
}

bool _validateName(String _userName) {
  // var _alpha = RegExp(r'^[a-zA-Z0-9]+$'); // For reference
  return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(_userName);
}

Future<void> saveUserInfo(String userName, String date, String time, String salt) async {
  var _database = '/home/rick/Databases/sqlite3dbs/usersdev.db';
  var process = 'sqlite3';
  var query = 'INSERT INTO users (username, date, time, salt) VALUES("$userName", "$date", "$time", "$salt")';
  await Process.start(process, [_database, query]);
}

Future<void> saveUserHash(String _hash, int _id) async {
  var _database = '/home/rick/Databases/sqlite3dbs/hashs/usershashdev.db';
  var process = 'sqlite3';
  var query = 'INSERT INTO hashs (id, hash) VALUES($_id, "$_hash")';
  await Process.start(process, [_database, query]);
}

Future<int> getLastId() async {
  var _database = '/home/rick/Databases/sqlite3dbs/usersdev.db';
  var query = 'sqlite3';
  var last = '';
  await Process.run(query, ['$_database', 'SELECT id FROM users'], stdoutEncoding: utf8).then((value) => last = value.stdout.toString().replaceAll('\n', ''));
  return int.parse(last.toString()[last.toString().length - 1]);
}