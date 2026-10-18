import 'package:flutter/material.dart';
import '../models/models.dart';

IconData speciesIcon(Species s) => Icons.pets;

/// Фирменный цвет вида животных; одинаково хорошо виден на светлом и тёмном фоне.
Color speciesColor(Species s) => switch (s) {
      Species.cattle => const Color(0xFFA1887F),
      Species.sheep => const Color(0xFF7986CB),
      Species.pig => const Color(0xFFF06292),
      Species.poultry => const Color(0xFFFFB74D),
    };

/// Форматирование: 12345.6 → «12 346», с digits=1 → «12 345,6».
String formatNumber(double value, {int digits = 0}) {
  final fixed = value.toStringAsFixed(digits);
  final parts = fixed.split('.');
  final integer = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '\u00A0',
  );
  return digits > 0 ? '$integer,${parts[1]}' : integer;
}

String formatRub(double value) => '${formatNumber(value)} ₽';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class SpeciesAvatar extends StatelessWidget {
  const SpeciesAvatar({super.key, required this.species});

  final Species species;

  @override
  Widget build(BuildContext context) {
    final color = speciesColor(species);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(speciesIcon(species), color: color),
    );
  }
}
