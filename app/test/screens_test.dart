/// Widget-тесты навигации и ключевых экранов приложения.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feeding_calculator/main.dart';
import 'package:feeding_calculator/screens/add_animal_screen.dart';
import 'package:feeding_calculator/screens/feed_catalog_screen.dart';

Future<void> pumpLogin(WidgetTester tester) async {
  await tester.pumpWidget(const FeedingCalculatorApp());
  await tester.pumpAndSettle();
}

Future<void> loginThroughPin(WidgetTester tester) async {
  await pumpLogin(tester);
  await tester.enterText(find.byKey(const Key('email_field')), 'farm@agro.ru');
  await tester.enterText(find.byKey(const Key('password_field')), 'secret');
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();
  // PIN-экран: вводим демо-код 1234.
  for (final d in ['1', '2', '3', '4']) {
    await tester.tap(find.byKey(Key('pin_key_$d')));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Экран входа отображает форму и заголовок', (tester) async {
    await pumpLogin(tester);
    expect(find.text('Свои Финансы'), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  testWidgets('Пустая форма не пускает дальше — показывает ошибки валидации',
      (tester) async {
    await pumpLogin(tester);
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    expect(find.text('Введите e-mail'), findsOneWidget);
    expect(find.text('Минимум 4 символа'), findsOneWidget);
    // Остались на экране входа.
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });

  testWidgets('Неверный PIN остаётся на экране с сообщением об ошибке',
      (tester) async {
    await pumpLogin(tester);
    await tester.enterText(find.byKey(const Key('email_field')), 'a@b.c');
    await tester.enterText(find.byKey(const Key('password_field')), 'pass');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Вход по PIN'), findsOneWidget);
    for (final d in ['9', '9', '9', '9']) {
      await tester.tap(find.byKey(Key('pin_key_$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Неверный PIN, попробуйте ещё раз'), findsOneWidget);
  });

  testWidgets('Полный путь вход → PIN → главный экран', (tester) async {
    await loginThroughPin(tester);
    expect(find.textContaining('Добрый день'), findsOneWidget);
    expect(find.text('Сводка по хозяйству на сегодня'), findsOneWidget);
    // Нижняя навигация из 5 вкладок.
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Животные'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);
  });

  testWidgets('Вкладка «Животные»: список и фильтр по виду', (tester) async {
    await loginThroughPin(tester);
    await tester.tap(find.text('Животные'));
    await tester.pumpAndSettle();

    // Тестовые данные хозяйства.
    expect(find.text('Бурёнка'), findsOneWidget);

    // Фильтр: только свиньи.
    await tester.tap(find.byKey(const Key('filter_pig')));
    await tester.pumpAndSettle();
    expect(find.text('Бурёнка'), findsNothing); // КРС скрыт
  });

  testWidgets('Тап по животному открывает экран деталей с таблицей рациона',
      (tester) async {
    await loginThroughPin(tester);
    await tester.tap(find.text('Животные'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('animal_tile_a1')));
    await tester.pumpAndSettle();

    expect(find.text('Бурёнка'), findsWidgets);
    expect(find.text('Корм'), findsOneWidget);
    expect(find.text('кг/сут'), findsOneWidget);
    expect(find.text('Одноразовый прогон без бэкенда'), findsNothing);
  });

  testWidgets('Форма добавления животного сохраняет запись', (tester) async {
    await loginThroughPin(tester);
    await tester.tap(find.text('Животные'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(AddAnimalScreen), findsOneWidget);
    await tester.enterText(find.byKey(const Key('name_field')), 'Тестовик');
    await tester.enterText(find.byKey(const Key('weight_field')), '60');
    await tester.tap(find.byKey(const Key('save_animal_button')));
    await tester.pumpAndSettle();

    expect(find.text('Тестовик'), findsOneWidget);
  });

  testWidgets('Вкладка «Год» показывает годовую потребность', (tester) async {
    await loginThroughPin(tester);
    await tester.tap(find.text('Год'));
    await tester.pumpAndSettle();
    expect(find.text('Годовая потребность'), findsOneWidget);
    expect(find.text('По видам кормов'), findsOneWidget);
    expect(find.textContaining('т/год'), findsWidgets);
  });

  testWidgets('Вкладка «Каталог» показывает справочник кормов', (tester) async {
    await loginThroughPin(tester);
    await tester.tap(find.text('Каталог'));
    await tester.pumpAndSettle();
    expect(find.byType(FeedCatalogScreen), findsOneWidget);
    // Таблица прокручивается горизонтально/вертикально — проверяем видимые ячейки.
    expect(find.text('Концентраты'), findsWidgets);
    expect(find.text('КЕ/кг'), findsWidgets);
  });

  testWidgets('Вкладка «Профиль» показывает данные хозяйства', (tester) async {
    await loginThroughPin(tester);
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    expect(find.text('Иван Петров'), findsOneWidget);
    expect(find.text('КФХ «Заря»'), findsWidgets);
  });

  testWidgets('Выход из профиля возвращает на экран входа', (tester) async {
    await loginThroughPin(tester);
    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();
    // Кнопка выхода может быть ниже вьюпорта — прокручиваем к ней.
    await tester.scrollUntilVisible(
      find.byKey(const Key('logout_tile')),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logout_tile')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}
