import 'package:flutter_test/flutter_test.dart';
import 'package:agrokorm/data/mock_data.dart';
import 'package:agrokorm/models/models.dart';
import 'package:agrokorm/services/feed_calculator.dart';

void main() {
  group('FeedCalculator', () {
    test('полные рационы для всех четырёх видов животных', () {
      for (final group in mockGroups) {
        final ration = FeedCalculator.build(group, feeds);
        expect(ration.isComplete, isTrue, reason: group.name);
        expect(ration.items, isNotEmpty, reason: group.name);
        expect(ration.dmKgPerHead, closeTo(FeedCalculator.dryMatterPerHead(group), 0.001), reason: group.name);
        expect(ration.items.every((item) => item.massKg > 0), isTrue, reason: group.name);
      }
      expect(mockGroups.map((g) => g.species).toSet(), Species.values.toSet());
    });

    test('доли рациона суммируются до единицы', () {
      for (final group in mockGroups) {
        expect(FeedCalculator.split(group).values.fold<double>(0, (sum, value) => sum + value), closeTo(1, 1e-9));
      }
    });

    test('молодняк получает большую норму, чем взрослые того же веса', () {
      const young = AnimalGroup(id: 'y', name: 'y', species: Species.cattle, purpose: Purpose.meat,
          housing: Housing.stall, heads: 1, ageDays: 100, avgWeightKg: 300, productivity: 0);
      const adult = AnimalGroup(id: 'a', name: 'a', species: Species.cattle, purpose: Purpose.meat,
          housing: Housing.stall, heads: 1, ageDays: 800, avgWeightKg: 300, productivity: 0);
      expect(FeedCalculator.dryMatterPerHead(young), greaterThan(FeedCalculator.dryMatterPerHead(adult)));
    });

    test('годовой расчёт учитывает поголовье, 365 дней и потери', () {
      const group = AnimalGroup(id: 'test', name: 'test', species: Species.pig, purpose: Purpose.meat,
          housing: Housing.stall, heads: 10, ageDays: 200, avgWeightKg: 60, productivity: 0);
      final plan = FeedCalculator.annualPlan([group], feeds);
      expect(plan.isComplete, isTrue);
      expect(plan.needs, hasLength(1));
      final ration = FeedCalculator.build(group, feeds);
      expect(plan.needs.single.tonnes, closeTo(ration.massKgPerHead * 10 * 365 * 1.05 / 1000, 1e-9));
    });

    test('не скрывает отсутствие подходящего корма', () {
      const group = AnimalGroup(id: 'missing', name: 'нет кормов', species: Species.cattle, purpose: Purpose.milk,
          housing: Housing.stall, heads: 3, ageDays: 800, avgWeightKg: 500, productivity: 20);
      final ration = FeedCalculator.build(group, const []);
      expect(ration.isComplete, isFalse);
      expect(ration.warnings, isNotEmpty);
      final plan = FeedCalculator.annualPlan([group], const []);
      expect(plan.isComplete, isFalse);
      expect(plan.needs, isEmpty);
    });

    test('не делит на нулевой процент сухого вещества', () {
      const group = AnimalGroup(id: 'pig', name: 'pig', species: Species.pig, purpose: Purpose.meat,
          housing: Housing.stall, heads: 1, ageDays: 200, avgWeightKg: 60, productivity: 0);
      const invalidFeed = Feed(id: 'bad', name: 'Плохой корм', kind: FeedKind.concentrate,
          dryMatterPercent: 0, pricePerTonRub: 100, species: {Species.pig}, purposes: {Purpose.meat});
      final ration = FeedCalculator.build(group, [invalidFeed]);
      expect(ration.isComplete, isFalse);
      expect(ration.items, isEmpty);
      expect(ration.warnings.join(' '), contains('сухого вещества'));
    });

    test('отклоняет некорректные параметры группы', () {
      const group = AnimalGroup(id: 'bad', name: 'bad', species: Species.pig, purpose: Purpose.meat,
          housing: Housing.stall, heads: 0, ageDays: 10, avgWeightKg: 20, productivity: 0);
      expect(() => FeedCalculator.dryMatterPerHead(group), throwsArgumentError);
    });

    test('годовой план на тестовых данных положительный и полный', () {
      final plan = FeedCalculator.annualPlan(mockGroups, feeds);
      expect(plan.isComplete, isTrue);
      expect(plan.needs, isNotEmpty);
      expect(plan.needs.every((n) => n.tonnes > 0 && n.costRub >= 0), isTrue);
    });
  });
}
