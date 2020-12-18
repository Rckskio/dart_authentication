import 'dart:cli';
import 'dart:io';
import 'dart:convert';
import 'package:encryption/decrypt.dart' as decrypt;
import 'package:encryption/default_path.dart' as _default_path;

var inputName = '';

void main() async{
  var uniqueName = false;

  while(uniqueName == false) {
    stdout.write('Username: ');
    inputName = stdin.readLineSync();
    var file = File(_default_path.path + inputName);
    if (file.existsSync()) {
      uniqueName = true;
    } else {
      print('Wrong username or username not registered!');
    }
  }

  final _userName = inputName;
  var _count = 0;

  while (true) {
    stdout.write('Password: ');
    var input = _readHidden();
    _count++;
    if (input.length < 8) {
      print('Attention! Password should be at least 8 characters long!');
    } else {
      final _password = input;
      final _userSalt = await getSalt(_userName);
      var _encrypted = await decrypt.decrypt(_userSalt, _password);
      if(await verifyAttempt(_userName, '$_encrypted')){
        print('Logged in Successfully!');
        exitCode = 0;
        exit(exitCode);
      } else {
        print('Wrong password!');
        if (_count > 3) { // Could make something to block more attempts for a few minutes. Need to learn.
          print('Too many wrong attempts, come back later!');
          exit(1);
        }
      }
    }
  }
}

// Function created by Brett Sutton from the project dcli https://github.com/bsutton/dcli/tree/0.34.6-linux
// Extracted from lib/src/functions/ask.dart and no changes were made.
String _readHidden() {
  const _backspace = 127;
  const _space = 32;
  const _ = 8;
  var value = <int>[];

  try {
    stdin.echoMode = false;
    stdin.lineMode = false;
    int char;
    do {
      char = stdin.readByteSync();
      if (char != 10) {
        if (char == _backspace) {
          if (value.isNotEmpty) {
            // move back a character,
            // print a space an move back again.
            // required to clear the current character
            // move back one space.
            stdout.writeCharCode(_);
            stdout.writeCharCode(_space);
            stdout.writeCharCode(_);
            value.removeLast();
          }
        } else {
          stdout.write('*');
          // we must wait for flush as only one flush can be outstanding at a time.
          waitFor<void>(stdout.flush());
          value.add(char);
        }
      }
    } while (char != 10);
  } finally {
    stdin.echoMode = true;
    stdin.lineMode = true;
  }

  // output a newline as we have suppressed it.
  print('');

  // return the entered value as a String.
  return Encoding.getByName('utf-8').decode(value);
}

Future getSalt(String _userName) async { // Could get the information from a Database.
  var _salt = [];
  await File(_default_path.path + _userName)
      .openRead()
      .map(utf8.decode)
      .transform(LineSplitter())
      .forEach((line) {
    if (line.contains('Salt:')) {
      _salt = line.split(' ');
    }
  });
  return _salt[1];
}

Future verifyAttempt(String _userName, String _encrypted) async{ //Again, could verify the information with a database
  var correct = false;
  await File(_default_path.path + _userName)
      .openRead()
      .map(utf8.decode)
      .transform(LineSplitter())
      .forEach((line) {
    if (line.contains('$_encrypted')) {
      correct = true;
    }
  });
  return correct;
}