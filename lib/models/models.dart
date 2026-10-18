enum Species { cattle, sheep, pig, poultry }

enum Purpose { milk, meat, eggs }

enum Housing { stall, pasture }

enum FeedKind { roughage, succulent, concentrate }

extension SpeciesX on Species {
  String get label => switch (this) {
        Species.cattle => 'КРС',
        Species.sheep => 'МРС',
        Species.pig => 'Свиньи',
        Species.poultry => 'Птица',
      };

  /// Возраст (дней), до которого животное считается молодняком с повышенной потребностью на рост.
  int get youngLimitDays => switch (this) {
        Species.cattle => 365,
        Species.sheep => 180,
        Species.pig => 120,
        Species.poultry => 42,
      };
}

extension PurposeX on Purpose {
  String get label => switch (this) {
        Purpose.milk => 'молоко',
        Purpose.meat => 'мясо',
        Purpose.eggs => 'яйца',
      };

  String get productivityUnit => switch (this) {
        Purpose.milk => 'л/сут',
        Purpose.meat => 'г/сут',
        Purpose.eggs => 'яиц/год',
      };
}

extension HousingX on Housing {
  String get label => this == Housing.stall ? 'Стойловое' : 'Пастбищное';

  /// Доля потерь при хранении и раздаче.
  double get lossFactor => this == Housing.stall ? 0.05 : 0.08;
}

extension FeedKindX on FeedKind {
  String get label => switch (this) {
        FeedKind.roughage => 'Грубый',
        FeedKind.succulent => 'Сочный',
        FeedKind.concentrate => 'Концентрат',
      };
}

class AnimalGroup {
  const AnimalGroup({
    required this.id,
    required this.name,
    required this.species,
    required this.purpose,
    required this.housing,
    required this.heads,
    required this.ageDays,
    required this.avgWeightKg,
    required this.productivity,
  });

  final String id;
  final String name;
  final Species species;
  final Purpose purpose;
  final Housing housing;
  final int heads;
  final int ageDays;
  final double avgWeightKg;

  /// Единица зависит от purpose: л/сут для молока, г/сут для мяса, яиц/год для яиц.
  final double productivity;
}

class Feed {
  const Feed({
    required this.id,
    required this.name,
    required this.kind,
    required this.dryMatterPercent,
    required this.pricePerTonRub,
    required this.species,
    this.purposes,
    this.housings,
  });

  final String id;
  final String name;
  final FeedKind kind;
  final double dryMatterPercent;
  final double pricePerTonRub;
  final Set<Species> species;

  /// null означает «подходит для любой цели».
  final Set<Purpose>? purposes;

  /// null означает «подходит для любого содержания».
  final Set<Housing>? housings;

  bool matches(AnimalGroup g) =>
      species.contains(g.species) &&
      (purposes == null || purposes!.contains(g.purpose)) &&
      (housings == null || housings!.contains(g.housing));
}
