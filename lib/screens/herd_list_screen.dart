import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../routes.dart';
import '../widgets/common.dart';

class HerdListScreen extends StatefulWidget {
  const HerdListScreen({super.key});

  @override
  State<HerdListScreen> createState() => _HerdListScreenState();
}

class _HerdListScreenState extends State<HerdListScreen> {
  Species? _filter;

  Widget _chip(String label, Species? species) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(label),
          selected: _filter == species,
          onSelected: (_) => setState(() => _filter = species),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final groups = mockGroups.where((g) => _filter == null || g.species == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Стадо и группы')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _chip('Все', null),
                for (final s in Species.values) _chip(s.label, s),
              ],
            ),
          ),
          Expanded(
            child: groups.isEmpty
                ? const Center(child: Text('Групп нет'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final g = groups[i];
                      return Card(
                        child: ListTile(
                          leading: SpeciesAvatar(species: g.species),
                          title: Text(g.name),
                          subtitle: Text(
                            '${g.species.label} · ${g.purpose.label} · ${g.heads} гол. · '
                            '${formatNumber(g.avgWeightKg, digits: g.avgWeightKg % 1 == 0 ? 0 : 1)} кг',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.pushNamed(context, AppRoutes.groupDetail, arguments: g),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
