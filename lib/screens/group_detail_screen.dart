import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/feed_calculator.dart';
import '../widgets/common.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key, required this.group});

  final AnimalGroup group;

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ration = FeedCalculator.build(group, feeds);
    final productivityDigits = group.purpose == Purpose.eggs ? 0 : 1;

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Параметры группы', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _row('Вид', group.species.label),
                  _row('Цель', group.purpose.label),
                  _row('Содержание', group.housing.label),
                  _row('Поголовье', '${group.heads} гол.'),
                  _row('Возраст', '${group.ageDays} дн.'),
                  _row('Средний вес', '${formatNumber(group.avgWeightKg, digits: 1)} кг'),
                  _row(
                    'Продуктивность',
                    '${formatNumber(group.productivity, digits: productivityDigits)} ${group.purpose.productivityUnit}',
                  ),
                ],
              ),
            ),
          ),
          if (ration.warnings.isNotEmpty) ...[
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Рацион рассчитан не полностью', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    for (final warning in ration.warnings) Text('• $warning'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          Text(ration.isComplete ? 'Суточный рацион на голову' : 'Доступная часть рациона', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (ration.items.isEmpty)
            const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Нет доступных кормов для расчёта'))),
          for (final item in ration.items)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.grass)),
                title: Text(item.feed.name),
                subtitle: Text('${item.kind.label} · СВ ${formatNumber(item.dmKg, digits: 2)} кг'),
                trailing: Text('${formatNumber(item.massKg, digits: 2)} кг'),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row(ration.isComplete ? 'Сухое вещество, кг/гол.' : 'Учтённое сухое вещество, кг/гол.', formatNumber(ration.dmKgPerHead, digits: 2)),
                  _row(ration.isComplete ? 'Масса корма, кг/гол.' : 'Учтённая масса корма, кг/гол.', formatNumber(ration.massKgPerHead, digits: 2)),
                  _row('Стоимость, ₽/гол. в сутки', formatNumber(ration.costPerHeadRub, digits: 2)),
                  _row('Стоимость в сутки на группу', formatRub(ration.costPerDayRub)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Расчёт демонстрационный. Для реального рациона используйте официальные нормативы и консультацию зоотехника.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
