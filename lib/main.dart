// lib/main.dart - Main entry point for the MoodFit app

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moodfit/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MoodFitApp());
}
