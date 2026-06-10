enum AppFlavor {
  dev,
  prod,
}

class AppEnv {
  static AppFlavor flavor = AppFlavor.dev;

  static String get appName {
    switch (flavor) {
      case AppFlavor.dev:
        return 'Ecommerce Dev';
      case AppFlavor.prod:
        return 'Ecommerce';
    }
  }

  static String get baseUrl {
    switch (flavor) {
      case AppFlavor.dev:
        return 'http://10.0.2.2:5000/api';
      case AppFlavor.prod:
        return 'https://api.yourdomain.com/api';
    }
  }

  static bool get isDev => flavor == AppFlavor.dev;
}