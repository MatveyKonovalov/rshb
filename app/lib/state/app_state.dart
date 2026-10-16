/// Провайдер состояния приложения (in-memory, без бэкенда).
library;

import 'package:flutter/foundation.dart';

import '../data/farm_data.dart';
import '../models/animal.dart';
import '../services/feeding_service.dart';

class AppState extends ChangeNotifier {
  final FarmData farm = FarmData();
  final FeedingService feeding = FeedingService();

  String demoPin = '1234';
  bool pinEnabled = true;

  String farmName = 'КФХ «Заря»';
  String region = 'Краснодарский край';
  String ownerName = 'Иван Петров';

  void addAnimal(Animal a) {
    farm.add(a);
    notifyListeners();
  }

  void removeAnimal(String id) {
    farm.remove(id);
    notifyListeners();
  }

  double get farmDailyFeedUnits => feeding.farmDailyFeedUnits(farm.animals);

  double get farmDailyKg =>
      feeding.farmDailyKg(farm.animals).values.fold(0.0, (s, v) => s + v);

  double get annualCostRub => feeding.annualCostRub(farm.animals);

  int get totalHeads => farm.totalHeads();
}
