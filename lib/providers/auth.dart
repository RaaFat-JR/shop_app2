import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userID;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userID;
  }

  Future<void> _authenticate(
      String email, String password, String phrase) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$phrase?key=AIzaSyA4ON0AA8HvAJ3gGWrBx5hGH8EiyHHPdkg");
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userID = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogOut();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'user': _userID,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedDaTa =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expireDate = DateTime.parse(extractedDaTa['expiryDate']);

    if (expireDate.isBefore(DateTime.now())) {
      return false;
    }

    _userID = extractedDaTa['user'];
    _token = extractedDaTa['token'];
    _expiryDate = expireDate;
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _expiryDate = null;
    _userID = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogOut() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
