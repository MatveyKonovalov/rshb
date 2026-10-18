import '../models/models.dart';

/// Строка рациона: один корм на одну голову в сутки.
class RationItem {
  const RationItem({
    required this.kind,
    required this.feed,
    required this.dmKg,
    required this.massKg,
  });

  final FeedKind kind;
  final Feed feed;
  /// Сухое вещество, кг/гол. в сутки.
  final double dmKg;
  /// Масса корма в натуральном виде, кг/гол. в сутки.
  final double massKg;

  double get costPerHeadDayRub => massKg / 1000 * feed.pricePerTonRub;
}

class Ration {
  const Ration({required this.group, required this.items, this.warnings = const []});

  final AnimalGroup group;
  final List<RationItem> items;
  /// Ненулевой список означает, что рацион рассчитан не полностью.
  final List<String> warnings;
  bool get isComplete => warnings.isEmpty;
  double get dmKgPerHead => items.fold(0.0, (s, i) => s + i.dmKg);
  double get massKgPerHead => items.fold(0.0, (s, i) => s + i.massKg);
  double get costPerHeadRub => items.fold(0.0, (s, i) => s + i.costPerHeadDayRub);
  double get costPerDayRub => costPerHeadRub * group.heads;
}

class AnnualNeed {
  const AnnualNeed({required this.feed, required this.tonnes});
  final Feed feed;
  final double tonnes;
  double get costRub => tonnes * feed.pricePerTonRub;
}

/// Результат годового расчёта. Предупреждения не позволяют принять частичный
/// расчёт за полную потребность хозяйства.
class AnnualPlan {
  const AnnualPlan({required this.needs, required this.warnings});
  final List<AnnualNeed> needs;
  final List<String> warnings;
  bool get isComplete => warnings.isEmpty;
}

/// Упрощённые коэффициенты для демонстрации логики. Не заменяют зоотехнический расчёт.
class FeedCalculator {
  const FeedCalculator._();

  static void _validateGroup(AnimalGroup g) {
    if (g.heads <= 0) throw ArgumentError.value(g.heads, 'heads', 'Поголовье должно быть больше нуля');
    if (g.ageDays < 0) throw ArgumentError.value(g.ageDays, 'ageDays', 'Возраст не может быть отрицательным');
    if (!g.avgWeightKg.isFinite || g.avgWeightKg <= 0) {
      throw ArgumentError.value(g.avgWeightKg, 'avgWeightKg', 'Вес должен быть положительным числом');
    }
    if (!g.productivity.isFinite || g.productivity < 0) {
      throw ArgumentError.value(g.productivity, 'productivity', 'Продуктивность не может быть отрицательной');
    }
  }

  /// Суточная потребность в сухом веществе на голову (кг).
  static double dryMatterPerHead(AnimalGroup g) {
    _validateGroup(g);
    final w = g.avgWeightKg;
    final p = g.productivity;
    final base = switch (g.species) {
      Species.cattle => 0.02 * w + (g.purpose == Purpose.milk ? 0.4 * p : 2.5 * p / 1000),
      Species.sheep => 0.025 * w + (g.purpose == Purpose.milk ? 0.3 * p : 2.5 * p / 1000),
      Species.pig => 0.015 * w + 2.5 * p / 1000,
      Species.poultry => g.purpose == Purpose.eggs
          ? 0.1 * (p <= 0 ? 1.0 : p / 300).clamp(0.75, 1.15).toDouble()
          : 0.02 * w + 1.8 * p / 1000,
    };
    final ageFactor = g.ageDays < g.species.youngLimitDays ? 1.1 : 1.0;
    return base * ageFactor;
  }

  /// Доля каждого типа корма в сухом веществе рациона; сумма долей равна 1.
  static Map<FeedKind, double> split(AnimalGroup g) {
    final pasture = g.housing == Housing.pasture;
    return switch (g.species) {
      Species.cattle => pasture ? _split(0.15, 0.55, 0.30) : _split(0.45, 0.25, 0.30),
      Species.sheep => pasture ? _split(0.15, 0.65, 0.20) : _split(0.60, 0.20, 0.20),
      Species.pig => _split(0, 0, 1),
      Species.poultry => _split(0, 0, 1),
    };
  }

  static Map<FeedKind, double> _split(double r, double s, double c) =>
      {FeedKind.roughage: r, FeedKind.succulent: s, FeedKind.concentrate: c};

  static Ration build(AnimalGroup g, List<Feed> catalog) {
    final dm = dryMatterPerHead(g);
    final items = <RationItem>[];
    final warnings = <String>[];
    final shares = split(g);

    for (final entry in shares.entries) {
      final kind = entry.key;
      final share = entry.value;
      if (share <= 0) continue;
      final candidates = catalog.where((f) => f.kind == kind && f.matches(g)).toList();
      if (candidates.isEmpty) {
        warnings.add('Нет подходящего корма категории «${kind.label.toLowerCase()}» для группы «${g.name}».');
        continue;
      }
      // Не выбираем молча некорректную запись из каталога.
      final feed = candidates.firstWhere(
        (f) => f.dryMatterPercent.isFinite && f.dryMatterPercent > 0 &&
            f.dryMatterPercent <= 100 && f.pricePerTonRub.isFinite && f.pricePerTonRub >= 0,
        orElse: () => candidates.first,
      );
      if (!feed.dryMatterPercent.isFinite || feed.dryMatterPercent <= 0 || feed.dryMatterPercent > 100) {
        warnings.add('У корма «${feed.name}» некорректно указана доля сухого вещества (должна быть > 0 и ≤ 100%).');
        continue;
      }
      if (!feed.pricePerTonRub.isFinite || feed.pricePerTonRub < 0) {
        warnings.add('У корма «${feed.name}» указана некорректная цена.');
        continue;
      }
      final dmKg = dm * share;
      items.add(RationItem(kind: kind, feed: feed, dmKg: dmKg, massKg: dmKg / (feed.dryMatterPercent / 100)));
    }
    return Ration(group: g, items: List.unmodifiable(items), warnings: List.unmodifiable(warnings));
  }

  /// Полный годовой план. Группы с неполным рационом отмечаются явно.
  static AnnualPlan annualPlan(List<AnimalGroup> groups, List<Feed> catalog) {
    final tonnes = <String, double>{};
    final feedById = <String, Feed>{};
    final warnings = <String>[];
    for (final g in groups) {
      final ration = build(g, catalog);
      if (!ration.isComplete) {
        warnings.addAll(ration.warnings);
        continue; // Не включаем неполный рацион в итог как будто он полный.
      }
      for (final item in ration.items) {
        final kg = item.massKg * g.heads * 365 * (1 + g.housing.lossFactor);
        tonnes.update(item.feed.id, (v) => v + kg / 1000, ifAbsent: () => kg / 1000);
        feedById[item.feed.id] = item.feed;
      }
    }
    final result = [
      for (final e in tonnes.entries) AnnualNeed(feed: feedById[e.key]!, tonnes: e.value),
    ]..sort((a, b) => b.tonnes.compareTo(a.tonnes));
    return AnnualPlan(needs: List.unmodifiable(result), warnings: List.unmodifiable(warnings));
  }

  /// Совместимость с прежним API; для интерфейса предпочтителен annualPlan,
  /// поскольку он также возвращает предупреждения о неполных группах.
  static List<AnnualNeed> annualNeeds(List<AnimalGroup> groups, List<Feed> catalog) =>
      annualPlan(groups, catalog).needs;
}
