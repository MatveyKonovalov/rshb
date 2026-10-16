/// Каталог кормов — тестовые справочные данные (без бэкенда).
library;

import '../models/animal.dart';
import '../models/feed.dart';

class FeedCatalog {
  /// Список всех кормов справочника.
  final List<Feed> feeds = const [
    // Концентраты
    Feed(id: 'grain_oat', name: 'Овёс', category: FeedCategory.concentrate,
        feedUnitsPerKg: 0.98, crudeProteinG: 100, dryMatterPercent: 85, pricePerTonRub: 14500),
    Feed(id: 'grain_barley', name: 'Ячмень', category: FeedCategory.concentrate,
        feedUnitsPerKg: 1.05, crudeProteinG: 102, dryMatterPercent: 86, pricePerTonRub: 15800),
    Feed(id: 'grain_wheat', name: 'Пшеница', category: FeedCategory.concentrate,
        feedUnitsPerKg: 1.24, crudeProteinG: 130, dryMatterPercent: 87, pricePerTonRub: 17200),
    Feed(id: 'cake_sunflower', name: 'Подсолнечниковый шрот', category: FeedCategory.concentrate,
        feedUnitsPerKg: 1.06, crudeProteinG: 480, dryMatterPercent: 88, pricePerTonRub: 26500),
    Feed(id: 'compound_pig', name: 'Комбикорм для свиней', category: FeedCategory.concentrate,
        feedUnitsPerKg: 1.08, crudeProteinG: 280, dryMatterPercent: 88, pricePerTonRub: 23000),
    Feed(id: 'compound_poultry', name: 'Комбикорм для птицы', category: FeedCategory.concentrate,
        feedUnitsPerKg: 1.12, crudeProteinG: 260, dryMatterPercent: 89, pricePerTonRub: 24800),
    // Грубые
    Feed(id: 'hay_meadow', name: 'Сено луговое', category: FeedCategory.coarse,
        feedUnitsPerKg: 0.45, crudeProteinG: 55, dryMatterPercent: 85, pricePerTonRub: 9800),
    Feed(id: 'hay_straw', name: 'Солома пшеничная', category: FeedCategory.coarse,
        feedUnitsPerKg: 0.25, crudeProteinG: 20, dryMatterPercent: 80, pricePerTonRub: 5200),
    // Сочные
    Feed(id: 'silo_corn', name: 'Силос кукурузный', category: FeedCategory.succulent,
        feedUnitsPerKg: 0.26, crudeProteinG: 32, dryMatterPercent: 32, pricePerTonRub: 4300),
    Feed(id: 'root_potato', name: 'Картофель', category: FeedCategory.succulent,
        feedUnitsPerKg: 0.31, crudeProteinG: 35, dryMatterPercent: 25, pricePerTonRub: 16000),
    // Минеральные
    Feed(id: 'salt', name: 'Соль кормовая', category: FeedCategory.mineral,
        feedUnitsPerKg: 0.0, crudeProteinG: 0, dryMatterPercent: 99, pricePerTonRub: 8500),
    Feed(id: 'bone_meal', name: 'Костная мука', category: FeedCategory.mineral,
        feedUnitsPerKg: 0.48, crudeProteinG: 200, dryMatterPercent: 92, pricePerTonRub: 31000),
  ];

  Feed byId(String id) => feeds.firstWhere((f) => f.id == id);

  List<Feed> byCategory(FeedCategory c) =>
      feeds.where((f) => f.category == c).toList();

  /// Выбор representative-корма категории с учётом вида животного.
  Feed pickRepresentative(FeedCategory category, AnimalSpecies species) {
    switch (category) {
      case FeedCategory.concentrate:
        switch (species) {
          case AnimalSpecies.pig:
            return byId('compound_pig');
          case AnimalSpecies.poultry:
            return byId('compound_poultry');
          case AnimalSpecies.cattle:
          case AnimalSpecies.sheepGoat:
            return byId('grain_oat');
        }
      case FeedCategory.coarse:
        return byId('hay_meadow');
      case FeedCategory.succulent:
        return byId(species == AnimalSpecies.poultry ? 'root_potato' : 'silo_corn');
      case FeedCategory.mineral:
        return byId('bone_meal');
    }
  }
}
