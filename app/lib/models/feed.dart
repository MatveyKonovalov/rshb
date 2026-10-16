/// Модель корма и категории кормов.
library;

/// Категория корма.
enum FeedCategory {
  concentrate('Концентраты', '🌾'),
  coarse('Грубые', '🌿'),
  succulent('Сочные', '🥕'),
  mineral('Минеральные', '⛏️');

  const FeedCategory(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Корм из каталога (справочник питательности).
class Feed {
  const Feed({
    required this.id,
    required this.name,
    required this.category,
    /// Кормовых единиц на 1 кг корма.
    required this.feedUnitsPerKg,
    /// Сырой протеин, г на корм. ед.
    required this.crudeProteinG,
    /// Сухое вещество, %.
    required this.dryMatterPercent,
    /// Цена за тонну, ₽.
    required this.pricePerTonRub,
  });

  final String id;
  final String name;
  final FeedCategory category;
  final double feedUnitsPerKg;
  final double crudeProteinG;
  final double dryMatterPercent;
  final double pricePerTonRub;
}

/// Строка рациона: сколько кг конкретного корма в сутки.
class RationItem {
  const RationItem({required this.feed, required this.kgPerDay});
  final Feed feed;
  final double kgPerDay;

  double get feedUnits => feed.feedUnitsPerKg * kgPerDay;

  /// Стоимость суточной дачи, ₽ (цена за тонну / 1000 = цена за кг).
  double get costPerDayRub => kgPerDay * feed.pricePerTonRub / 1000;
}

/// Результат расчёта суточной нормы для одного животного.
class DailyNorm {
  const DailyNorm({
    required this.totalFeedUnits,
    required this.items,
    required this.categoryShares,
  });

  /// Всего кормовых единиц в сутки.
  final double totalFeedUnits;
  /// Раскладка по кормам.
  final List<RationItem> items;
  /// Доли категорий кормов от общих КЕ (сумма = 1.0).
  final Map<FeedCategory, double> categoryShares;

  double get totalKgPerDay => items.fold(0, (s, i) => s + i.kgPerDay);

  double get costPerDayRub => items.fold(0, (s, i) => s + i.costPerDayRub);
}

/// Итог годовой потребности по одному корму.
class AnnualFeedNeed {
  const AnnualFeedNeed({required this.feed, required this.kgPerYear});
  final Feed feed;
  final double kgPerYear;

  double get tonsPerYear => kgPerYear / 1000;
  double get costPerYearRub => tonsPerYear * feed.pricePerTonRub;
}
