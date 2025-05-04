// lib/providers/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:moodfit/data/models/user_model.dart';
import 'package:moodfit/data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    // Check if user is already authenticated
    _initUser();
  }

  Future<void> _initUser() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      try {
        _user = await _authService.getUserData(currentUser.uid);
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _authService.isEmailVerified();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      // Get user data from Firestore
      _user = await _authService.getUserData(userCredential.user!.uid);

      notifyListeners();
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      _error = errorMessage;
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _user = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    _setLoading(true);
    _error = null;

    try {
      final userCredential = await _authService.registerWithEmailAndPassword(
        email,
        password,
        name,
      );

      // Send email verification
      await _authService.sendEmailVerification();

      // Get user data from Firestore
      _user = await _authService.getUserData(userCredential.user!.uid);

      notifyListeners();
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      _error = errorMessage;
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _user = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_user == null) return;

    _setLoading(true);

    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      // Update local user object
      _user = _user!.copyWith(
        displayName: displayName ?? _user!.displayName,
        photoUrl: photoUrl ?? _user!.photoUrl,
        updatedAt: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
