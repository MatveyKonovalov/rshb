/// Экран 9: профиль хозяйства и настройки.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Профиль'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Text('👨‍🌾', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 12),
          Center(
              child: Text(state.ownerName,
                  style: Theme.of(context).textTheme.titleLarge)),
          Center(
              child: Text(state.farmName,
                  style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Регион'),
                    subtitle: Text(state.region)),
                const Divider(height: 1),
                ListTile(
                    leading: const Icon(Icons.pets_outlined),
                    title: const Text('Поголовье'),
                    subtitle: Text('${state.totalHeads} голов')),
                const Divider(height: 1),
                SwitchListTile(
                  key: const Key('pin_switch'),
                  secondary: const Icon(Icons.pin_outlined),
                  title: const Text('Вход по PIN-коду'),
                  subtitle: Text('Текущий демо-PIN: ${state.demoPin}'),
                  value: state.pinEnabled,
                  onChanged: (v) =>
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  v ? 'PIN включён' : 'PIN отключён (демо)'))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('О приложении'),
                  subtitle: const Text(
                      'Свои Финансы • расчёт норм кормления\nВерсия 1.0.0 (демо без бэкенда)'),
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('logout_tile'),
                  leading: const Icon(Icons.logout),
                  title: const Text('Выйти'),
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
