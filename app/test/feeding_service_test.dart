/// Unit-тесты сервиса расчёта норм кормления и годовой потребности.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:feeding_calculator/models/animal.dart';
import 'package:feeding_calculator/models/feed.dart';
import 'package:feeding_calculator/services/feed_catalog.dart';
import 'package:feeding_calculator/services/feeding_service.dart';

Animal makeAnimal({
  String id = 't1',
  AnimalSpecies species = AnimalSpecies.cattle,
  int ageMonths = 48,
  double weightKg = 500,
  Productivity productivity = Productivity.none,
  HousingCondition housing = HousingCondition.barn,
  int headCount = 1,
}) =>
    Animal(
      id: id,
      name: 'Тест',
      species: species,
      ageMonths: ageMonths,
      weightKg: weightKg,
      productivity: productivity,
      housing: housing,
      headCount: headCount,
    );

void main() {
  group('Поддерживающая потребность (КЕ/сут)', () {
    test('КРС: 0.02*вес + 1.5', () {
      expect(FeedingService.maintenanceFeedUnits(AnimalSpecies.cattle, 500),
          closeTo(11.5, 1e-9));
    });

    test('МРС: 0.04*вес + 0.3', () {
      expect(FeedingService.maintenanceFeedUnits(AnimalSpecies.sheepGoat, 60),
          closeTo(2.7, 1e-9));
    });

    test('Свиньи: 0.03*вес + 0.4', () {
      expect(FeedingService.maintenanceFeedUnits(AnimalSpecies.pig, 100),
          closeTo(3.4, 1e-9));
    });

    test('Птица: 0.11 + 0.002*вес', () {
      expect(FeedingService.maintenanceFeedUnits(AnimalSpecies.poultry, 2),
          closeTo(0.114, 1e-9));
    });
  });

  group('Продуктивная часть рациона', () {
    test('Молоко: 0.45 КЕ на литр', () {
      expect(FeedingService.productionFeedUnits(const Productivity(milkLiters: 20)),
          closeTo(9.0, 1e-9));
    });

    test('Привес: 0.5 КЕ на кг', () {
      expect(FeedingService.productionFeedUnits(const Productivity(dailyGainKg: 0.8)),
          closeTo(0.4, 1e-9));
    });

    test('Яйца: 0.02 КЕ на яйцо', () {
      expect(FeedingService.productionFeedUnits(const Productivity(eggsPerDay: 0.9)),
          closeTo(0.018, 1e-9));
    });

    test('Нулевая продуктивность даёт 0 КЕ', () {
      expect(FeedingService.productionFeedUnits(Productivity.none), 0.0);
    });
  });

  group('Суточная норма с учётом возраста и условий', () {
    test('Дойная корова 500 кг, 20 л/сут, стойловое: (11.5 + 9.0) * 1.00', () {
      final a = makeAnimal(
          weightKg: 500, productivity: const Productivity(milkLiters: 20));
      expect(FeedingService.dailyFeedUnits(a), closeTo(20.5, 1e-9));
    });

    test('Молодняк (до 6 мес.): поддержка × 1.15, продукция игнорируется', () {
      final young = makeAnimal(
          ageMonths: 4,
          weightKg: 100,
          productivity: const Productivity(milkLiters: 5));
      // (0.02*100 + 1.5) * 1.15 * 1.00 = 4.025
      expect(FeedingService.dailyFeedUnits(young), closeTo(4.025, 1e-9));
    });

    test('Пастбищное содержание снижает норму (коэф. 0.95)', () {
      final barn = makeAnimal(weightKg: 500);
      final pasture = makeAnimal(weightKg: 500, housing: HousingCondition.pasture);
      expect(FeedingService.dailyFeedUnits(pasture),
          closeTo(FeedingService.dailyFeedUnits(barn) * 0.95, 1e-9));
    });

    test('Клеточное содержание птицы повышает норму (коэф. 1.05)', () {
      final cage = makeAnimal(
        species: AnimalSpecies.poultry,
        weightKg: 2,
        housing: HousingCondition.cage,
      );
      // (0.11 + 0.004) * 1.05
      expect(FeedingService.dailyFeedUnits(cage), closeTo(0.1197, 1e-6));
    });
  });

  group('Доли категорий кормов', () {
    test('Сумма долей для всех видов равна 1.0 после нормализации', () {
      for (final s in AnimalSpecies.values) {
        final shares = FeedingService.normalizeShares(
            FeedingService.categoryShares(makeAnimal(species: s)));
        expect(shares.values.fold<double>(0, (a, b) => a + b), closeTo(1.0, 1e-9));
      }
    });

    test('У высокопродуктивной коровы (≥15 л) доля концентратов 0.55', () {
      final a = makeAnimal(productivity: const Productivity(milkLiters: 18));
      expect(FeedingService.categoryShares(a)[FeedCategory.concentrate],
          closeTo(0.55, 1e-9));
    });

    test('У малопродуктивной коровы (<15 л) доля концентратов 0.45', () {
      final a = makeAnimal(productivity: const Productivity(milkLiters: 8));
      expect(FeedingService.categoryShares(a)[FeedCategory.concentrate],
          closeTo(0.45, 1e-9));
    });

    test('У птицы грубые корма исключены (доля 0)', () {
      final a = makeAnimal(species: AnimalSpecies.poultry, weightKg: 2);
      expect(FeedingService.categoryShares(a)[FeedCategory.coarse], 0.0);
    });
  });

  group('Раскладка суточного рациона', () {
    final service = FeedingService();

    test('Сумма КЕ по строкам рациона равна общей суточной норме', () {
      final a = makeAnimal(productivity: const Productivity(milkLiters: 20));
      final norm = service.calculateDailyNorm(a);
      final sumKe = norm.items.fold<double>(0, (s, i) => s + i.feedUnits);
      expect(sumKe, closeTo(norm.totalFeedUnits, 1e-9));
    });

    test('Все нормы положительные, пустых строк нет', () {
      for (final s in AnimalSpecies.values) {
        final norm = service.calculateDailyNorm(makeAnimal(species: s, weightKg: 50));
        expect(norm.items, isNotEmpty);
        for (final item in norm.items) {
          expect(item.kgPerDay, greaterThan(0));
        }
      }
    });

    test('Для свиней representative-концентрат — комбикорм для свиней', () {
      final norm = service.calculateDailyNorm(
          makeAnimal(species: AnimalSpecies.pig, weightKg: 100));
      final conc = norm.items.where((i) => i.feed.category == FeedCategory.concentrate);
      expect(conc.every((i) => i.feed.id == 'compound_pig'), isTrue);
    });

    test('Стоимость суточной дачи положительна', () {
      final norm = service.calculateDailyNorm(makeAnimal());
      expect(norm.costPerDayRub, greaterThan(0));
    });
  });

  group('Годовая потребность хозяйства', () {
    final service = FeedingService(catalog: FeedCatalog());
    final animals = <Animal>[
      makeAnimal(id: 'c1', weightKg: 500, productivity: const Productivity(milkLiters: 20)),
      makeAnimal(id: 'p1', species: AnimalSpecies.pig, weightKg: 100,
          productivity: const Productivity(dailyGainKg: 0.8), headCount: 10),
    ];

    test('Суточная потребность по кормам учитывает headCount группы', () {
      final dailyPigOnly = service.farmDailyKg([animals[1]]);
      final dailyBoth = service.farmDailyKg(animals);
      // Добавление коровы не должно уменьшить потребление ни одного корма.
      for (final entry in dailyPigOnly.entries) {
        expect(dailyBoth[entry.key]!, greaterThanOrEqualTo(entry.value));
      }
      // Комбикорм для свиней используется только группой свиней:
      // удвоенная численность -> пропорциональный рост нормы.
      final doubled = service.farmDailyKg([
        makeAnimal(id: 'p2', species: AnimalSpecies.pig, weightKg: 100,
            productivity: const Productivity(dailyGainKg: 0.8), headCount: 20),
      ]);
      expect(doubled['compound_pig']!,
          closeTo(dailyPigOnly['compound_pig']! * 2, 1e-9));
    });

    test('Годовая потребность = суточная × 365, список отсортирован по убыванию', () {
      final annual = service.annualNeed(animals);
      final daily = service.farmDailyKg(animals);
      for (final n in annual) {
        expect(n.kgPerYear, closeTo(daily[n.feed.id]! * 365, 1e-6));
      }
      for (var i = 1; i < annual.length; i++) {
        expect(annual[i - 1].kgPerYear, greaterThanOrEqualTo(annual[i].kgPerYear));
      }
    });

    test('Годовая стоимость совпадает с суммой строк потребности', () {
      final annual = service.annualNeed(animals);
      final expected =
          annual.fold<double>(0, (s, n) => s + n.tonsPerYear * n.feed.pricePerTonRub);
      expect(service.annualCostRub(animals), closeTo(expected, 1e-6));
      expect(service.annualCostRub(animals), greaterThan(0));
    });

    test('Общие КЕ хозяйства умножаются на поголовье', () {
      final single = makeAnimal(id: 'x1', headCount: 1);
      final group = makeAnimal(id: 'x2', headCount: 5);
      expect(service.farmDailyFeedUnits([group]),
          closeTo(service.farmDailyFeedUnits([single]) * 5, 1e-9));
    });

    test('Пустое хозяйство не даёт потребности', () {
      expect(service.annualNeed([]), isEmpty);
      expect(service.annualCostRub([]), 0.0);
      expect(service.farmDailyFeedUnits([]), 0.0);
    });
  });

  group('Каталог кормов', () {
    final catalog = FeedCatalog();

    test('12 кормов, id уникальны', () {
      expect(catalog.feeds.length, 12);
      expect(catalog.feeds.map((f) => f.id).toSet().length, 12);
    });

    test('byId бросает исключение для неизвестного корма', () {
      expect(() => catalog.byId('nope'), throwsA(isA<StateError>()));
    });

    test('Каждая категория содержит хотя бы один корм', () {
      for (final c in FeedCategory.values) {
        expect(catalog.byCategory(c), isNotEmpty);
      }
    });
  });
}
