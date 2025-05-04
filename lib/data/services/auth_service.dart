// lib/data/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:moodfit/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current authenticated user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print("Error in signInWithEmailAndPassword: $e");
      }
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!, displayName);
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print("Error in registerWithEmailAndPassword: $e");
      }
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String displayName) async {
    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'email': user.email,
      'displayName': displayName,
      'photoUrl': user.photoURL,
      'preferences': {},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("Error in signOut: $e");
      }
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      if (kDebugMode) {
        print("Error in sendEmailVerification: $e");
      }
      rethrow;
    }
  }

  // Check if email is verified
  bool isEmailVerified() {
    return currentUser?.emailVerified ?? false;
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data()!;

        // Convert Firestore Timestamps to DateTime
        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          data['createdAt'] = data['createdAt'].toDate().toIso8601String();
        }
        if (data['updatedAt'] != null && data['updatedAt'] is Timestamp) {
          data['updatedAt'] = data['updatedAt'].toDate().toIso8601String();
        }

        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Error in getUserData: $e");
      }
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      final user = currentUser;
      if (user == null) return;

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error in updateProfile: $e");
      }
      rethrow;
    }
  }
}
