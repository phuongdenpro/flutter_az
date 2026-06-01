import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_restapi/app/app.dart';
import 'package:flutter_restapi/core/constants/my_http_overrides.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
