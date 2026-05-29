import 'package:flutter/material.dart';
import 'package:flutter_dio/core/network/api_client.dart';
import 'package:go_router/go_router.dart';

// import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/router/app_router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;
  late final GoRouter router;
  late final Future<void> initFuture;

  @override
  void initState() {
    super.initState();
    tokenStorage = TokenStorage();
    apiClient = ApiClient(tokenStorage);
    router = AppRouter.createRouter(tokenStorage);
    initFuture = tokenStorage.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp.router(
          title: 'HTTP & Storage Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              primary: Colors.indigo,
              secondary: Colors.indigoAccent,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey[50],
          ),
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}