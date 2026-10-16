/// Тестовые данные хозяйства (in-memory, без бэкенда).
library;

import '../models/animal.dart';

class FarmData {
  FarmData() {
    animals = [
      Animal(
        id: 'a1',
        name: 'Бурёнка',
        species: AnimalSpecies.cattle,
        ageMonths: 48,
        weightKg: 520,
        productivity: const Productivity(milkLiters: 18),
        housing: HousingCondition.barn,
        group: 'Дойное стадо',
      ),
      Animal(
        id: 'a2',
        name: 'Зорька',
        species: AnimalSpecies.cattle,
        ageMonths: 60,
        weightKg: 480,
        productivity: const Productivity(milkLiters: 9),
        housing: HousingCondition.mixed,
        group: 'Дойное стадо',
      ),
      Animal(
        id: 'a3',
        name: 'Телёнок Гром',
        species: AnimalSpecies.cattle,
        ageMonths: 4,
        weightKg: 120,
        housing: HousingCondition.barn,
        group: 'Молодняк КРС',
      ),
      Animal(
        id: 'a4',
        name: 'Откормыши КРС (группа)',
        species: AnimalSpecies.cattle,
        ageMonths: 14,
        weightKg: 350,
        productivity: const Productivity(dailyGainKg: 0.9),
        housing: HousingCondition.barn,
        headCount: 12,
        group: 'Откорм КРС',
      ),
      Animal(
        id: 'a5',
        name: 'Козы пуховые (группа)',
        species: AnimalSpecies.sheepGoat,
        ageMonths: 30,
        weightKg: 55,
        productivity: const Productivity(milkLiters: 2.5),
        housing: HousingCondition.pasture,
        headCount: 18,
        group: 'МРС',
      ),
      Animal(
        id: 'a6',
        name: 'Овцы маточные (группа)',
        species: AnimalSpecies.sheepGoat,
        ageMonths: 24,
        weightKg: 65,
        housing: HousingCondition.pasture,
        headCount: 25,
        group: 'МРС',
      ),
      Animal(
        id: 'a7',
        name: 'Свиньи откорм (группа)',
        species: AnimalSpecies.pig,
        ageMonths: 7,
        weightKg: 95,
        productivity: const Productivity(dailyGainKg: 0.75),
        housing: HousingCondition.barn,
        headCount: 30,
        group: 'Свинокомплекс',
      ),
      Animal(
        id: 'a8',
        name: 'Свинушка Хавроша',
        species: AnimalSpecies.pig,
        ageMonths: 10,
        weightKg: 110,
        housing: HousingCondition.mixed,
        group: 'Свинокомплекс',
      ),
      Animal(
        id: 'a9',
        name: 'Куры несушки (стада)',
        species: AnimalSpecies.poultry,
        ageMonths: 11,
        weightKg: 1.9,
        productivity: const Productivity(eggsPerDay: 0.85),
        housing: HousingCondition.cage,
        headCount: 120,
        group: 'Птичник',
      ),
      Animal(
        id: 'a10',
        name: 'Утки мясные (партия)',
        species: AnimalSpecies.poultry,
        ageMonths: 2,
        weightKg: 2.6,
        housing: HousingCondition.barn,
        headCount: 40,
        group: 'Птичник',
      ),
    ];
  }

  late List<Animal> animals;

  int _counter = 100;

  void add(Animal a) => animals.add(a);

  Animal create({
    required String name,
    required AnimalSpecies species,
    required int ageMonths,
    required double weightKg,
    Productivity productivity = Productivity.none,
    HousingCondition housing = HousingCondition.barn,
    int headCount = 1,
    String? group,
  }) {
    final a = Animal(
      id: 'a${_counter++}',
      name: name,
      species: species,
      ageMonths: ageMonths,
      weightKg: weightKg,
      productivity: productivity,
      housing: housing,
      headCount: headCount,
      group: group,
    );
    add(a);
    return a;
  }

  void remove(String id) => animals.removeWhere((a) => a.id == id);

  int totalHeads() => animals.fold(0, (s, a) => s + a.headCount);
}
