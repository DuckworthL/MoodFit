// lib/models/user_model.dart - User data model for application
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;
  final String? profilePicUrl;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
    this.profilePicUrl,
    this.preferences,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      profilePicUrl: data['profilePicUrl'],
      preferences: data['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'profilePicUrl': profilePicUrl,
      'preferences': preferences ?? {},
    };
  }

  UserModel copyWith({
    String? name,
    String? profilePicUrl,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      createdAt: createdAt,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      preferences: preferences ?? this.preferences,
    );
  }
}
