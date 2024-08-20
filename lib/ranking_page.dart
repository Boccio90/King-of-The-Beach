import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  final List<Map<String, dynamic>> playersWithNumbers;

  const RankingPage({super.key, required this.playersWithNumbers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classifica')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Numero')),
            DataColumn(label: Text('Nome')),
            DataColumn(label: Text('Differenza Punti')),
            DataColumn(label: Text('Vittorie')),
          ],
          rows: playersWithNumbers.map((player) {
            return DataRow(cells: [
              DataCell(Text('${player['number']}')),
              DataCell(Text(player['name'])),
              DataCell(Text('${player['difference'] ?? 0}')),
              DataCell(Text('${player['victories'] ?? 0}')),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
