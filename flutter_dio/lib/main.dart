import 'package:flutter/material.dart';
import 'package:flutter_dio/app.dart';
import 'package:flutter_dio/core/constants/my_http_overrides.dart';
import 'features/auth/pages/login_page.dart';
import 'dart:io';


void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}