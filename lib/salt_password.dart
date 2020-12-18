String saltPassword(String salt, String password) {
  var _first = salt.split('');
  var _second = password.split('');
  var _third = _first + _second;
  var last = _shuffle(_third);
  return last.join();
}

List _shuffle(List salt) {
  if (salt.length <= 2) {
    var ending = [];
    ending.add(salt.last);
    ending.add(salt.first);
    return ending;
  }

  var shuffled = [];
  shuffled.add(salt.last);
  shuffled.add(salt.first);
  salt.removeAt(0);
  salt.removeAt(salt.length - 1);
  shuffled.addAll(_shuffle(salt));
  return shuffled;
}