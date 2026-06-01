import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_restapi/app/router/app_router.dart';
import 'package:flutter_restapi/config/app_constants.dart';
import 'package:flutter_restapi/core/di/app_dependencies.dart';
import 'package:flutter_restapi/core/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  GoRouter? _router;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    await AppDependencies.instance.init();
    _router = AppRouter.createRouter(AppDependencies.instance.tokenStorage);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || _router == null) {
          return MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final router = _router!;

        return MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}
