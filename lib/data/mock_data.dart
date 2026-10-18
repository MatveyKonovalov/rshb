import '../models/models.dart';

const farmName = 'КФХ «Заря»';
const ownerName = 'Сергей Петрович Иванов';
const farmRegion = 'Воронежская область';

/// Порядок важен: для каждого вида и типа корма берётся первый подходящий.
const feeds = <Feed>[
  Feed(id: 'hay', name: 'Сено луговое', kind: FeedKind.roughage, dryMatterPercent: 86, pricePerTonRub: 9000, species: {Species.cattle, Species.sheep}),
  Feed(id: 'straw', name: 'Солома пшеничная', kind: FeedKind.roughage, dryMatterPercent: 88, pricePerTonRub: 4000, species: {Species.cattle, Species.sheep}),
  Feed(id: 'silage', name: 'Силос кукурузный', kind: FeedKind.succulent, dryMatterPercent: 30, pricePerTonRub: 2500, species: {Species.cattle, Species.sheep}, housings: {Housing.stall}),
  Feed(id: 'grass', name: 'Пастбищная трава', kind: FeedKind.succulent, dryMatterPercent: 20, pricePerTonRub: 600, species: {Species.cattle, Species.sheep}, housings: {Housing.pasture}),
  Feed(id: 'cattle_mix', name: 'Комбикорм для КРС', kind: FeedKind.concentrate, dryMatterPercent: 88, pricePerTonRub: 18000, species: {Species.cattle}),
  Feed(id: 'pig_mix', name: 'Комбикорм для откорма свиней', kind: FeedKind.concentrate, dryMatterPercent: 88, pricePerTonRub: 22000, species: {Species.pig}, purposes: {Purpose.meat}),
  Feed(id: 'layer_mix', name: 'Комбикорм для кур-несушек', kind: FeedKind.concentrate, dryMatterPercent: 88, pricePerTonRub: 24000, species: {Species.poultry}, purposes: {Purpose.eggs}),
  Feed(id: 'broiler_mix', name: 'Комбикорм для бройлеров', kind: FeedKind.concentrate, dryMatterPercent: 88, pricePerTonRub: 26000, species: {Species.poultry}, purposes: {Purpose.meat}),
  Feed(id: 'barley', name: 'Ячмень фуражный', kind: FeedKind.concentrate, dryMatterPercent: 86, pricePerTonRub: 14000, species: {Species.cattle, Species.sheep, Species.pig}),
];

const mockGroups = <AnimalGroup>[
  AnimalGroup(id: 'g1', name: 'Дойное стадо', species: Species.cattle, purpose: Purpose.milk, housing: Housing.stall, heads: 120, ageDays: 1200, avgWeightKg: 600, productivity: 25),
  AnimalGroup(id: 'g2', name: 'Молодняк на откорме', species: Species.cattle, purpose: Purpose.meat, housing: Housing.pasture, heads: 80, ageDays: 200, avgWeightKg: 280, productivity: 900),
  AnimalGroup(id: 'g3', name: 'Овцематки', species: Species.sheep, purpose: Purpose.milk, housing: Housing.pasture, heads: 300, ageDays: 900, avgWeightKg: 65, productivity: 1.2),
  AnimalGroup(id: 'g4', name: 'Свиньи на откорме', species: Species.pig, purpose: Purpose.meat, housing: Housing.stall, heads: 400, ageDays: 150, avgWeightKg: 60, productivity: 700),
  AnimalGroup(id: 'g5', name: 'Куры-несушки', species: Species.poultry, purpose: Purpose.eggs, housing: Housing.stall, heads: 2000, ageDays: 300, avgWeightKg: 2, productivity: 300),
  AnimalGroup(id: 'g6', name: 'Бройлеры', species: Species.poultry, purpose: Purpose.meat, housing: Housing.stall, heads: 5000, ageDays: 38, avgWeightKg: 1.8, productivity: 55),
];
