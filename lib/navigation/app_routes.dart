class AppRouter {
  final String path;
  final String name;
  AppRouter({required this.path, required this.name});
}

class Routes {
  static AppRouter splashScreen = AppRouter(path: '/splashScreen', name: 'SplashScreen');
  static AppRouter languageScreen = AppRouter(path: '/languageScreen', name: 'LanguageScreen');
  static AppRouter loginScreen = AppRouter(path: '/loginScreen', name: 'LoginScreen');
  static AppRouter loginOtpScreen = AppRouter(path: '/loginOtpScreen', name: 'LoginOtpScreen');

  static AppRouter homeScreen = AppRouter(path: '/homeScreen', name: 'HomeScreen');
  static AppRouter profileScreen = AppRouter(path: '/profileScreen', name: 'ProfileScreen');
  static AppRouter my3fScreen = AppRouter(path: '/my3fScreen', name: 'My3fScreen');
  static AppRouter requestsScreen = AppRouter(path: '/requestsScreen', name: 'RequestsScreen');
  static AppRouter customerCareScreen = AppRouter(path: '/customerCareScreen', name: 'CustomerCareScreen');

  static AppRouter pageNotFound = AppRouter(path: '/page-not-found', name: 'Page Not Found');

  static AppRouter testScreen = AppRouter(path: '/test', name: 'Test');

}
