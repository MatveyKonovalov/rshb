import 'package:flutter/material.dart';
import 'models/models.dart';
import 'routes.dart';
import 'screens/annual_needs_screen.dart';
import 'screens/group_detail_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/pin_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const AgroKormApp());

class AgroKormApp extends StatelessWidget {
  const AgroKormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) => MaterialApp(
        title: 'АгроКорм',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.pin: (_) => const PinScreen(),
          AppRoutes.main: (_) => const MainShell(),
          AppRoutes.annualNeeds: (_) => const AnnualNeedsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.groupDetail) {
            final group = settings.arguments as AnimalGroup;
            return MaterialPageRoute(builder: (_) => GroupDetailScreen(group: group));
          }
          return null;
        },
      ),
    );
  }
}
