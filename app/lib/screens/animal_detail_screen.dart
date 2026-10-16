/// Экран 5: карточка животного с деталями расчёта нормы.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/feed.dart';
import '../state/app_state.dart';

class AnimalDetailScreen extends StatelessWidget {
  const AnimalDetailScreen({super.key, required this.animalId});

  final String animalId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final animals = state.farm.animals.where((a) => a.id == animalId).toList();

    if (animals.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Животное не найдено')),
      );
    }
    final a = animals.first;
    final norm = state.feeding.calculateDailyNorm(a);

    return Scaffold(
      appBar: AppBar(
        title: Text(a.name),
        actions: [
          IconButton(
            key: const Key('delete_animal'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Удалить запись?'),
                  content: Text('«${a.name}» будет удалён из стада.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Отмена')),
                    FilledButton(
                        key: const Key('confirm_delete'),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Удалить')),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                state.removeAnimal(a.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(a.species.emoji, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${a.species.label} • ${a.group ?? 'без группы'}',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text('Голов: ${a.headCount}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _param(context, 'Возраст', a.ageLabel),
                  _param(context, 'Вес', '${a.weightKg} кг'),
                  _param(context, 'Содержание', a.housing.label),
                  if (!a.productivity.isZero) ...[
                    if (a.productivity.milkLiters > 0)
                      _param(context, 'Надой', '${a.productivity.milkLiters} л/сут'),
                    if (a.productivity.dailyGainKg > 0)
                      _param(context, 'Привес', '${a.productivity.dailyGainKg} кг/сут'),
                    if (a.productivity.eggsPerDay > 0)
                      _param(context, 'Яйца', '${a.productivity.eggsPerDay} шт/сут'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Суточная норма кормления',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.eco_rounded),
              title: Text('Всего: ${norm.totalFeedUnits.toStringAsFixed(2)} корм. ед.'),
              subtitle: Text('Масса дачи: ${norm.totalKgPerDay.toStringAsFixed(1)} кг/сут • '
                  'Стоимость: ${norm.costPerDayRub.toStringAsFixed(0)} ₽/сут'
                  '${a.headCount > 1 ? ' × ${a.headCount} гол.' : ''}'),
            ),
          ),
          const SizedBox(height: 8),
          Table(
            key: const Key('ration_table'),
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: [
                  _headerCell('Корм'),
                  _headerCell('Доля'),
                  _headerCell('кг/сут'),
                  _headerCell('КЕ'),
                ],
              ),
              for (final item in norm.items)
                TableRow(children: [
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('${item.feed.category.emoji} ${item.feed.name}')),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                          '${(norm.categoryShares[item.feed.category]! * 100).toStringAsFixed(0)}%')),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(item.kgPerDay.toStringAsFixed(2))),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(item.feedUnits.toStringAsFixed(2))),
                ]),
            ],
          ),
          const SizedBox(height: 16),
          Text('Год на одно животное: ${(norm.totalKgPerDay * 365).toStringAsFixed(0)} кг кормов, '
              '${(norm.costPerDayRub * 365).toStringAsFixed(0)} ₽',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _headerCell(String title) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _param(BuildContext context, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: TextStyle(color: Colors.grey.shade700)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

/// Переименование для совместимости имён категорий в UI.
typedef FeedCat = FeedCategory;
