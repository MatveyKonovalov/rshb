import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/feed_calculator.dart';
import '../widgets/common.dart';

class AnnualNeedsScreen extends StatelessWidget {
  const AnnualNeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = FeedCalculator.annualPlan(mockGroups, feeds);
    final needs = plan.needs;
    final totalTonnes = needs.fold<double>(0, (s, n) => s + n.tonnes);
    final totalCost = needs.fold<double>(0, (s, n) => s + n.costRub);

    return Scaffold(
      appBar: AppBar(title: const Text('Годовая потребность')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (plan.warnings.isNotEmpty) ...[
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Расчёт неполный', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Группы с неполным рационом не включены в итоговую потребность. Проверьте каталог кормов.'),
                    const SizedBox(height: 8),
                    for (final warning in plan.warnings) Text('• $warning'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            color: theme.colorScheme.primaryContainer,
            child: ListTile(
              title: const Text('Всего кормов в год'),
              subtitle: Text('${formatNumber(totalTonnes, digits: 1)} т, с учётом потерь'),
              trailing: Text(formatRub(totalCost), style: theme.textTheme.titleSmall),
            ),
          ),
          const SizedBox(height: 12),
          for (final n in needs)
            Card(
              child: ListTile(
                title: Text(n.feed.name),
                subtitle: Text('${n.feed.kind.label} · СВ ${n.feed.dryMatterPercent.toStringAsFixed(0)}%'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${formatNumber(n.tonnes, digits: 1)} т', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(formatRub(n.costRub), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Демонстрационная оценка: суточная масса корма × 365 × поголовье × (1 + потери). Потери: 5% в стойле, 8% на пастбище. Нормы не заменяют расчёт зоотехника.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
