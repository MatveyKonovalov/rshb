import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initials = ownerName.split(' ').map((p) => p[0]).take(2).join();

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: scheme.primary.withValues(alpha: 0.2),
              child: Text(
                initials,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: scheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(ownerName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
          Center(
            child: Text(farmName, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.place_outlined),
                  title: Text('Регион'),
                  subtitle: Text(farmRegion),
                ),
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.calculate_outlined),
                  title: const Text('Годовая потребность кормов'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.annualNeeds),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Тема оформления', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: appThemeMode,
                    builder: (context, mode, _) => SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: ThemeMode.system, label: Text('Авто'), icon: Icon(Icons.brightness_auto)),
                          ButtonSegment(value: ThemeMode.light, label: Text('Светлая'), icon: Icon(Icons.light_mode)),
                          ButtonSegment(value: ThemeMode.dark, label: Text('Тёмная'), icon: Icon(Icons.dark_mode)),
                        ],
                        selected: {mode},
                        onSelectionChanged: (s) => appThemeMode.value = s.first,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              title: const Text('Уведомления о нормах'),
              value: _notifications,
              onChanged: (v) => setState(() => _notifications = v),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false),
          ),
        ],
      ),
    );
  }
}
