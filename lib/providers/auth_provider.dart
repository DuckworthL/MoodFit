// lib/providers/auth_provider.dart - Authentication state management
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moodfit/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  bool _isNewUser = false; // Added flag for new users

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get user => _userModel;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get uid => _auth.currentUser?.uid;
  bool get isNewUser => _isNewUser; // Getter for new user flag

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _userModel = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        _userModel = UserModel.fromFirestore(userDoc);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toJson());

      _userModel = newUser;
      _isNewUser = true; // Set flag for new user
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reset the new user flag after onboarding
  void resetNewUserFlag() {
    _isNewUser = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document if it doesn't exist (important for demo accounts)
      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Create a basic user profile
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'email': email,
            'name': email.split('@')[0], // Use email prefix as name
            'createdAt': FieldValue.serverTimestamp(),
            'preferences': {}
          });
        }
      }

      _isNewUser = false; // Not a new user when signing in
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile(
      {String? name,
      String? profilePicUrl,
      Map<String, dynamic>? preferences}) async {
    try {
      if (_userModel == null || _auth.currentUser == null) return false;

      _isLoading = true;
      notifyListeners();

      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (profilePicUrl != null) updateData['profilePicUrl'] = profilePicUrl;
      if (preferences != null) updateData['preferences'] = preferences;

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(updateData);

      _userModel = _userModel!.copyWith(
        name: name,
        profilePicUrl: profilePicUrl,
        preferences: preferences,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> resetError() async {
    _error = null;
    notifyListeners();
  }
}
