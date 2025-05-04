// lib/data/models/user_model.dart - User data model

import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      preferences: json['preferences'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static Future<UserModel?> fromMap(Map<String, dynamic> map) async {
    try {
      return UserModel(
        id: map['id'] ?? '',
        email: map['email'] ?? '',
        displayName: map['displayName'],
        photoUrl: map['photoUrl'],
        preferences: map['preferences'],
        createdAt:
            map['createdAt'] != null
                ? (map['createdAt'] is DateTime
                    ? map['createdAt']
                    : map['createdAt'].toDate())
                : DateTime.now(),
        updatedAt:
            map['updatedAt'] != null
                ? (map['updatedAt'] is DateTime
                    ? map['updatedAt']
                    : map['updatedAt'].toDate())
                : DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error converting map to UserModel: $e');
      }
      return null;
    }
  }
}
