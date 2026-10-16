/// Экран 8: годовая потребность хозяйства в кормах.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class AnnualNeedScreen extends StatelessWidget {
  const AnnualNeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final needs = state.feeding.annualNeed(state.farm.animals);
    final totalKg = needs.fold(0.0, (s, n) => s + n.kgPerYear);
    final totalRub = needs.fold(0.0, (s, n) => s + n.costPerYearRub);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Годовая потребность'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${state.farmName} • ${state.region}',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                      'Поголовье: ${state.totalHeads} гол. • '
                      'Кормов на год: ${(totalKg / 1000).toStringAsFixed(1)} т • '
                      'Стоимость: ${(totalRub / 1000).toStringAsFixed(0)} тыс. ₽',
                      key: const Key('annual_summary'),
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('По видам кормов',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final n in needs)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Text(n.feed.category.emoji,
                    style: const TextStyle(fontSize: 24)),
                title: Text(n.feed.name),
                subtitle: Text(n.feed.category.label),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${n.tonsPerYear.toStringAsFixed(2)} т/год',
                        style: Theme.of(context).textTheme.titleSmall),
                    Text('${(n.costPerYearRub / 1000).toStringAsFixed(0)} тыс. ₽',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('export_button'),
            icon: const Icon(Icons.download_outlined),
            label: const Text('Сформировать список закупки (демо)'),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Список закупки сохранён в демо-буфер (без бэкенда)'))),
          ),
        ],
      ),
    );
  }
}
