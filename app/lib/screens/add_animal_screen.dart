/// Экран 6: форма добавления животного.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/animal.dart';
import '../state/app_state.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  static const routeName = '/add-animal';

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _weight = TextEditingController(text: '500');
  final _age = TextEditingController(text: '36');
  final _heads = TextEditingController(text: '1');
  final _milk = TextEditingController();
  final _gain = TextEditingController();
  final _eggs = TextEditingController();

  AnimalSpecies _species = AnimalSpecies.cattle;
  HousingCondition _housing = HousingCondition.barn;

  @override
  void dispose() {
    for (final c in [_name, _weight, _age, _heads, _milk, _gain, _eggs]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      c.text.isEmpty ? null : double.tryParse(c.text.replaceAll(',', '.'));

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    state.addAnimal(Animal(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      species: _species,
      ageMonths: int.parse(_age.text),
      weightKg: _num(_weight)!,
      housing: _housing,
      headCount: int.parse(_heads.text),
      productivity: Productivity(
        milkLiters: _num(_milk) ?? 0,
        dailyGainKg: _num(_gain) ?? 0,
        eggsPerDay: _num(_eggs) ?? 0,
      ),
    ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('«${_name.text}» добавлен в стадо')));
  }

  Widget _field(TextEditingController c, String label, Key key,
      {bool numeric = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        key: key,
        controller: c,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: numeric
            ? (v) {
                if (v == null || v.isEmpty) return 'Укажите значение';
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Число > 0';
                return null;
              }
            : (v) => (v == null || v.trim().isEmpty) ? 'Укажите кличку' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новое животное')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_name, 'Кличка / название группы', const Key('name_field'),
                numeric: false),
            const SizedBox(height: 8),
            DropdownButtonFormField<AnimalSpecies>(
              key: const Key('species_field'),
              value: _species,
              decoration:
                  const InputDecoration(labelText: 'Вид', border: OutlineInputBorder()),
              items: [
                for (final s in AnimalSpecies.values)
                  DropdownMenuItem(value: s, child: Text('${s.emoji} ${s.label}')),
              ],
              onChanged: (v) => setState(() => _species = v!),
            ),
            Row(
              children: [
                Expanded(child: _field(_age, 'Возраст, мес.', const Key('age_field'))),
                const SizedBox(width: 10),
                Expanded(child: _field(_weight, 'Вес, кг', const Key('weight_field'))),
              ],
            ),
            Row(
              children: [
                Expanded(child: _field(_heads, 'Голов', const Key('heads_field'))),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: DropdownButtonFormField<HousingCondition>(
                      key: const Key('housing_field'),
                      value: _housing,
                      decoration: const InputDecoration(
                          labelText: 'Содержание', border: OutlineInputBorder()),
                      items: [
                        for (final h in HousingCondition.values)
                          DropdownMenuItem(value: h, child: Text(h.label)),
                      ],
                      onChanged: (v) => setState(() => _housing = v!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Продуктивность (по желанию)',
                style: Theme.of(context).textTheme.titleSmall),
            _field(_milk, 'Надой, л/сут (КРС, МРС)', const Key('milk_field')),
            _field(_gain, 'Привес, кг/сут (КРС, свиньи)', const Key('gain_field')),
            _field(_eggs, 'Яйца, шт/сут (птица)', const Key('eggs_field')),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save_animal_button'),
              onPressed: _save,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Добавить и рассчитать норму'),
            ),
          ],
        ),
      ),
    );
  }
}
