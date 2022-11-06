import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthException implements Exception {
  String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? utilizador;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }
  isLogged() {
    return utilizador != null;
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      utilizador = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    utilizador = _auth.currentUser;
    notifyListeners();
  }

  signup(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('Weak password');
      }
      if (e.code == 'email-already-in-use') {
        throw AuthException('This email is already registerd');
      }
    }
  }

  login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Email not found. Sign up');
      }
      if (e.code == 'wrong-password') {
        throw AuthException('Password incorrect. Try again!');
      }
    }
  }

  logout() async {
    await _auth.signOut();
    _getUser();
  }
}
