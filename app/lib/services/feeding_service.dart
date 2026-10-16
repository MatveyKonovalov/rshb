/// Сервис расчёта норм кормления и годовой потребности хозяйства.
library;

import '../models/animal.dart';
import '../models/feed.dart';
import 'feed_catalog.dart';

/// Доли категорий кормов от суточных КЕ для вида животного.
typedef CategoryShares = Map<FeedCategory, double>;

class FeedingService {
  FeedingService({FeedCatalog? catalog}) : catalog = catalog ?? FeedCatalog();

  final FeedCatalog catalog;

  static const int daysPerYear = 365;

  /// Базовая потребность на поддержание жизни, корм. ед.
  /// Упрощённая норма: 0.3 КЕ на 100 кг живого веса + 0.2 КЕ константы.
  static double maintenanceFeedUnits(AnimalSpecies species, double weightKg) {
    switch (species) {
      case AnimalSpecies.cattle:
        return 0.02 * weightKg + 1.5;
      case AnimalSpecies.sheepGoat:
        return 0.04 * weightKg + 0.3;
      case AnimalSpecies.pig:
        return 0.03 * weightKg + 0.4;
      case AnimalSpecies.poultry:
        // Для птицы вес одной особи мал — базовая норма фиксирована.
        return 0.11 + 0.002 * weightKg;
    }
  }

  /// Потребность на продукцию, корм. ед./сут.
  static double productionFeedUnits(Productivity p) {
    var ke = 0.0;
    if (p.milkLiters > 0) ke += p.milkLiters * 0.45; // ~0.45 КЕ на литр молока
    if (p.dailyGainKg > 0) ke += p.dailyGainKg * 0.5; // привес свиней/КРС
    if (p.eggsPerDay > 0) ke += p.eggsPerDay * 0.02; // ~2 КЕ на 100 яиц
    return ke;
  }

  /// Коэффициент молодняка: до 6 мес. — продукция не учитывается,
  /// норма = поддержка × 1.15 (рост).
  static double _youngMultiplier(Animal a) => a.isYoung ? 1.15 : 1.0;

  /// Суточная потребность в кормовых единицах с учётом условий содержания.
  static double dailyFeedUnits(Animal a) {
    final base = maintenanceFeedUnits(a.species, a.weightKg) * _youngMultiplier(a);
    final prod = a.isYoung ? 0.0 : productionFeedUnits(a.productivity);
    return (base + prod) * a.housing.coefficient;
  }

  /// Доли категорий кормов. Для высокопродуктивных коров доля концентратов
  /// растёт (до 55%), для птицы грубые корма исключены.
  static CategoryShares categoryShares(Animal a) {
    switch (a.species) {
      case AnimalSpecies.cattle:
        if (a.isYoung) {
          return {
            FeedCategory.concentrate: 0.55,
            FeedCategory.coarse: 0.25,
            FeedCategory.succulent: 0.15,
            FeedCategory.mineral: 0.05,
          };
        }
        final milk = a.productivity.milkLiters;
        final conc = milk >= 15 ? 0.55 : (milk > 0 ? 0.45 : 0.30);
        return {
          FeedCategory.concentrate: conc,
          FeedCategory.coarse: 0.25,
          FeedCategory.succulent: 0.35 - (conc - 0.30) * 0.5,
          FeedCategory.mineral: 0.05,
        };
      case AnimalSpecies.sheepGoat:
        return {
          FeedCategory.concentrate: a.isYoung ? 0.40 : 0.25,
          FeedCategory.coarse: 0.50,
          FeedCategory.succulent: 0.20,
          FeedCategory.mineral: 0.05,
        };
      case AnimalSpecies.pig:
        return {
          FeedCategory.concentrate: 0.70,
          FeedCategory.coarse: 0.05,
          FeedCategory.succulent: 0.20,
          FeedCategory.mineral: 0.05,
        };
      case AnimalSpecies.poultry:
        return {
          FeedCategory.concentrate: 0.90,
          FeedCategory.coarse: 0.0,
          FeedCategory.succulent: 0.05,
          FeedCategory.mineral: 0.05,
        };
    }
  }

  /// Нормализация долей, чтобы сумма была равна 1.0.
  static CategoryShares normalizeShares(CategoryShares shares) {
    final total = shares.values.fold<double>(0, (s, v) => s + v);
    if (total == 0) return shares;
    return shares.map((k, v) => MapEntry(k, v / total));
  }

  /// Полный расчёт суточной нормы животного: раскладка по кормам каталога.
  DailyNorm calculateDailyNorm(Animal a) {
    final ke = dailyFeedUnits(a);
    final shares = normalizeShares(categoryShares(a));
    final items = <RationItem>[];

    for (final entry in shares.entries) {
      if (entry.value <= 0) continue;
      final feed = catalog.pickRepresentative(entry.key, a.species);
      final kg = (ke * entry.value) / feed.feedUnitsPerKg;
      items.add(RationItem(feed: feed, kgPerDay: kg));
    }

    return DailyNorm(totalFeedUnits: ke, items: items, categoryShares: shares);
  }

  /// Суточная потребность всего хозяйства по каждому корму (кг),
  /// с учётом headCount записи.
  Map<String, double> farmDailyKg(List<Animal> animals) {
    final result = <String, double>{};
    for (final a in animals) {
      final norm = calculateDailyNorm(a);
      for (final item in norm.items) {
        result.update(item.feed.id,
            (v) => v + item.kgPerDay * a.headCount,
            ifAbsent: () => item.kgPerDay * a.headCount);
      }
    }
    return result;
  }

  /// Годовая потребность хозяйства в кормах.
  List<AnnualFeedNeed> annualNeed(List<Animal> animals) {
    final daily = farmDailyKg(animals);
    final list = <AnnualFeedNeed>[];
    for (final entry in daily.entries) {
      final feed = catalog.byId(entry.key);
      list.add(AnnualFeedNeed(feed: feed, kgPerYear: entry.value * daysPerYear));
    }
    list.sort((a, b) => b.kgPerYear.compareTo(a.kgPerYear));
    return list;
  }

  /// Итоговая годовая стоимость кормов, ₽.
  double annualCostRub(List<Animal> animals) =>
      annualNeed(animals).fold(0, (s, n) => s + n.costPerYearRub);

  /// Общая суточная потребность хозяйства в КЕ.
  double farmDailyFeedUnits(List<Animal> animals) => animals.fold(
      0.0, (s, a) => s + dailyFeedUnits(a) * a.headCount);
}
