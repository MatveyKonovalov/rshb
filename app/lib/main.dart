/// Агро-приложение «Свои Финансы»: расчёт норм кормления.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/add_animal_screen.dart';
import 'screens/animal_detail_screen.dart';
import 'screens/animals_screen.dart';
import 'screens/annual_need_screen.dart';
import 'screens/feed_catalog_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/profile_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const FeedingCalculatorApp());
}

class FeedingCalculatorApp extends StatelessWidget {
  const FeedingCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Свои Финансы — Кормление',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginScreen(),
          '/pin': (_) => const PinScreen(),
          '/main': (_) => const MainShell(),
          '/animals': (_) => const AnimalsScreen(embedded: true),
          AddAnimalScreen.routeName: (_) => const AddAnimalScreen(),
          FeedCatalogScreen.routeName: (_) => const FeedCatalogScreen(),
        },
      ),
    );
  }
}

/// Оболочка с нижней навигацией: 5 вкладок + push-экраны.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    AnimalsScreen(),
    AnnualNeedScreen(),
    FeedCatalogScreen(embedded: true),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.pets_outlined), selectedIcon: Icon(Icons.pets), label: 'Животные'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Год'),
          NavigationDestination(icon: Icon(Icons.table_rows_outlined), selectedIcon: Icon(Icons.table_rows), label: 'Каталог'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}

/// Переход к деталям животного.
void openAnimalDetail(BuildContext context, String animalId) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AnimalDetailScreen(animalId: animalId)),
  );
}
