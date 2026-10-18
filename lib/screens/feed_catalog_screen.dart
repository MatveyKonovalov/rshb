import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class FeedCatalogScreen extends StatefulWidget {
  const FeedCatalogScreen({super.key});

  @override
  State<FeedCatalogScreen> createState() => _FeedCatalogScreenState();
}

class _FeedCatalogScreenState extends State<FeedCatalogScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final list = feeds.where((f) => f.name.toLowerCase().contains(q)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Каталог кормов')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск корма',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Ничего не найдено'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Корм')),
                          DataColumn(label: Text('Тип')),
                          DataColumn(label: Text('СВ'), numeric: true),
                          DataColumn(label: Text('₽/т'), numeric: true),
                          DataColumn(label: Text('Виды')),
                        ],
                        rows: [
                          for (final Feed f in list)
                            DataRow(cells: [
                              DataCell(Text(f.name)),
                              DataCell(Text(f.kind.label)),
                              DataCell(Text('${f.dryMatterPercent.toStringAsFixed(0)}%')),
                              DataCell(Text(formatNumber(f.pricePerTonRub))),
                              DataCell(Text(f.species.map((s) => s.label).join(', '))),
                            ]),
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
