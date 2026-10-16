/// Экран 3: главный экран — сводка хозяйства.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import 'add_animal_screen.dart';
import 'animal_detail_screen.dart';
import 'feed_catalog_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _fmt(double v, int digits) =>
      v.toStringAsFixed(digits).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.farmName),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_outlined), onPressed: () {})
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('fab_add_animal'),
        heroTag: 'fab_add',
        icon: const Icon(Icons.add),
        label: const Text('Животное'),
        onPressed: () => Navigator.pushNamed(context, AddAnimalScreen.routeName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Добрый день, ${state.ownerName.split(' ').first}! 👋',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Сводка по хозяйству на сегодня',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              MetricCard(
                icon: Icons.pets,
                value: '${state.totalHeads}',
                caption: 'голов в хозяйстве',
              ),
              MetricCard(
                icon: Icons.scale,
                value: '${_fmt(state.farmDailyKg, 0)} кг',
                caption: 'кормов в сутки',
                color: Colors.deepOrange,
              ),
              MetricCard(
                icon: Icons.eco_rounded,
                value: '${_fmt(state.farmDailyFeedUnits, 0)} КЕ',
                caption: 'корм. единиц в сутки',
                color: Colors.teal,
              ),
              MetricCard(
                icon: Icons.payments_outlined,
                value: '${_fmt(state.annualCostRub / 1000000, 2)} млн ₽',
                caption: 'корма на год (стоимость)',
                color: Colors.indigo,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuickAction(
                    icon: Icons.add_circle_outline,
                    label: 'Добавить',
                    onTap: () =>
                        Navigator.pushNamed(context, AddAnimalScreen.routeName),
                  ),
                  QuickAction(
                    icon: Icons.list_alt_outlined,
                    label: 'Животные',
                    onTap: () => Navigator.pushNamed(context, '/animals'),
                  ),
                  QuickAction(
                    icon: Icons.table_rows_outlined,
                    label: 'Каталог кормов',
                    onTap: () =>
                        Navigator.pushNamed(context, FeedCatalogScreen.routeName),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Последние животные', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...state.farm.animals.reversed.take(4).map((a) {
            final norm = state.feeding.calculateDailyNorm(a);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading:
                    Text(a.species.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(a.name),
                subtitle: Text(
                    '${a.species.label} • ${a.ageLabel} • ${a.weightKg} кг • '
                    '${norm.totalKgPerDay.toStringAsFixed(1)} кг/сут'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AnimalDetailScreen(animalId: a.id)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
