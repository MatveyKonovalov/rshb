/// Экран 4: список животных с фильтром по видам.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../state/app_state.dart';
import 'add_animal_screen.dart';
import 'animal_detail_screen.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key, this.embedded = false});

  /// true — экран открыт как отдельный маршрут (с кнопкой «назад»).
  final bool embedded;

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  AnimalSpecies? _filter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final animals = _filter == null
        ? state.farm.animals
        : state.farm.animals.where((a) => a.species == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.embedded,
        title: const Text('Животные'),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('fab_add_animal2'),
        heroTag: 'fab_add2',
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, AddAnimalScreen.routeName),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Все'),
                  selected: _filter == null,
                  onSelected: (_) => setState(() => _filter = null),
                ),
                for (final s in AnimalSpecies.values) ...[
                  const SizedBox(width: 6),
                  ChoiceChip(
                    key: Key('filter_${s.name}'),
                    avatar: Text(s.emoji),
                    label: Text(s.label),
                    selected: _filter == s,
                    onSelected: (_) => setState(() => _filter = s),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: animals.isEmpty
                ? const Center(child: Text('Нет животных этого вида'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: animals.length,
                    itemBuilder: (context, i) {
                      final a = animals[i];
                      final norm = state.feeding.calculateDailyNorm(a);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          key: Key('animal_tile_${a.id}'),
                          leading: Text(a.species.emoji,
                              style: const TextStyle(fontSize: 28)),
                          title: Text(a.name +
                              (a.headCount > 1 ? ' (${a.headCount} гол.)' : '')),
                          subtitle: Text(
                              '${a.group ?? a.species.label} • ${a.ageLabel} • ${a.weightKg} кг'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${norm.totalFeedUnits.toStringAsFixed(1)} КЕ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall),
                              Text('${norm.totalKgPerDay.toStringAsFixed(1)} кг/сут',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AnimalDetailScreen(animalId: a.id)),
                          ),
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
