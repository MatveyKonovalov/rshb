/// Модели данных животных и условий содержания.
library;

/// Вид животного.
enum AnimalSpecies {
  cattle('КРС', '🐄'),
  sheepGoat('МРС', '🐑'),
  pig('Свиньи', '🐖'),
  poultry('Птица', '🐔');

  const AnimalSpecies(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Условия содержания — влияют на коэффициент рациона.
enum HousingCondition {
  barn('Стойловое', 1.00),
  pasture('Пастбищное', 0.95),
  mixed('Смешанное', 0.98),
  cage('Клеточное (птица)', 1.05);

  const HousingCondition(this.label, this.coefficient);
  final String label;
  /// Коэффициент коррекции суточной нормы кормовых единиц.
  final double coefficient;
}

/// Продуктивность: молоко (л/сут), привес (кг/сут) или яйценоскость (шт/сут).
class Productivity {
  const Productivity({this.milkLiters = 0, this.dailyGainKg = 0, this.eggsPerDay = 0});

  final double milkLiters;
  final double dailyGainKg;
  final double eggsPerDay;

  static const none = Productivity();

  bool get isZero => milkLiters == 0 && dailyGainKg == 0 && eggsPerDay == 0;
}

/// Животное в хозяйстве.
class Animal {
  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.ageMonths,
    required this.weightKg,
    this.productivity = Productivity.none,
    this.housing = HousingCondition.barn,
    this.headCount = 1,
    this.group,
  });

  final String id;
  final String name;
  final AnimalSpecies species;
  /// Возраст в месяцах.
  final int ageMonths;
  /// Живой вес, кг (для птицы — вес одной особи).
  final double weightKg;
  final Productivity productivity;
  final HousingCondition housing;
  /// Количество голов, представляемых этой записью (группа).
  final int headCount;
  /// Название производственной группы (например «Дойное стадо»).
  final String? group;

  bool get isYoung => ageMonths <= 6;

  String get ageLabel {
    if (ageMonths < 12) return '$ageMonths мес.';
    final y = ageMonths ~/ 12;
    final m = ageMonths % 12;
    return m == 0 ? '$y лет' : '$y г. $m мес.';
  }
}
