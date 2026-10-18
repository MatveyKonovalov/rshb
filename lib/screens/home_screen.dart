import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../routes.dart';
import '../services/feed_calculator.dart';
import '../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final heads = mockGroups.fold<int>(0, (s, g) => s + g.heads);
    final rations = mockGroups.map((g) => FeedCalculator.build(g, feeds)).toList();
    final dailyCost = rations.where((r) => r.isComplete)
        .fold<double>(0, (s, r) => s + r.costPerDayRub);
    final annualPlan = FeedCalculator.annualPlan(mockGroups, feeds);
    final annualTonnes = annualPlan.needs.fold<double>(0, (s, n) => s + n.tonnes);

    return Scaffold(
      appBar: AppBar(title: Text(farmName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Добрый день,',
            style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
          Text(
            ownerName.split(' ').first,
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.pets,
                  label: 'Поголовье, гол.',
                  value: formatNumber(heads.toDouble()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Корма в год, т',
                  value: formatNumber(annualTonnes),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(Icons.payments_outlined, color: scheme.primary),
              title: const Text('Затраты на корма в сутки'),
              trailing: Text(
                formatRub(dailyCost),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (annualPlan.warnings.isNotEmpty) ...[
            Card(
              color: scheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: const Text('Есть неполные рационы'),
                subtitle: Text('Групп с проблемами: ${rations.where((r) => !r.isComplete).length}. Годовой итог может быть неполным.'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.calculate),
            label: const Text('Годовая потребность кормов'),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.annualNeeds),
          ),
          const SizedBox(height: 24),
          Text('Группы', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final AnimalGroup g in mockGroups) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: SpeciesAvatar(species: g.species),
                title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${g.species.label} · ${g.heads} гол.'),
                trailing: Text(
                  '${FeedCalculator.build(g, feeds).isComplete ? formatRub(FeedCalculator.build(g, feeds).costPerDayRub) : '—'}/сут',
                  style: theme.textTheme.bodySmall,
                ),
                onTap: () => Navigator.pushNamed(context, AppRoutes.groupDetail, arguments: g),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
