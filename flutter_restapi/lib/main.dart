import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restapi/core/constants/my_http_overrides.dart';
import 'app.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
