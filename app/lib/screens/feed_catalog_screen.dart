/// Экран 7: каталог кормов (таблица питательности).
library;

import 'package:flutter/material.dart';

import '../services/feed_catalog.dart';

class FeedCatalogScreen extends StatelessWidget {
  const FeedCatalogScreen({super.key, this.embedded = false});

  final bool embedded;

  static const routeName = '/catalog';

  @override
  Widget build(BuildContext context) {
    final feeds = FeedCatalog().feeds;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: embedded,
        title: const Text('Каталог кормов'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Справочник питательности и цен (тестовые данные). '
              'КЕ — кормовые единицы на 1 кг, СП — сырой протеин, г/корм. ед.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                child: DataTable(
                  key: const Key('catalog_table'),
                  headingRowColor:
                      WidgetStateProperty.all(Colors.grey.shade100),
                  columns: const [
                    DataColumn(label: Text('Корм')),
                    DataColumn(label: Text('Категория')),
                    DataColumn(
                        numeric: true, label: Text('КЕ/кг')),
                    DataColumn(
                        numeric: true, label: Text('СП, г')),
                    DataColumn(numeric: true, label: Text('СВ, %')),
                    DataColumn(numeric: true, label: Text('₽/т')),
                  ],
                  rows: [
                    for (final f in feeds)
                      DataRow(
                        cells: [
                          DataCell(Text('${f.category.emoji} ${f.name}')),
                          DataCell(Text(f.category.label)),
                          DataCell(Text(f.feedUnitsPerKg.toStringAsFixed(2))),
                          DataCell(Text(f.crudeProteinG.toStringAsFixed(0))),
                          DataCell(Text(f.dryMatterPercent.toStringAsFixed(0))),
                          DataCell(Text(
                              f.pricePerTonRub.toStringAsFixed(0))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
