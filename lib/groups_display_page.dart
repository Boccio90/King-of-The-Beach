import 'package:flutter/material.dart';

class GroupsDisplayPage extends StatelessWidget {
  final List<Map<String, dynamic>> playersWithNumbers;

  const GroupsDisplayPage({super.key, required this.playersWithNumbers});

  @override
  Widget build(BuildContext context) {
    // Separare i giocatori in due gruppi: pari e dispari
    List<Map<String, dynamic>> groupEven = playersWithNumbers.where((player) => player['number'] % 2 == 0).toList();
    List<Map<String, dynamic>> groupOdd = playersWithNumbers.where((player) => player['number'] % 2 != 0).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gironi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Girone Pari', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...groupEven.map((player) => ListTile(
                  title: Text('${player['number']} - ${player['name']}'),
                )),
            const SizedBox(height: 20),
            const Text('Girone Dispari', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...groupOdd.map((player) => ListTile(
                  title: Text('${player['number']} - ${player['name']}'),
                )),
            const SizedBox(height: 20), // Spazio aggiuntivo per separare il bottone
            ElevatedButton(
              onPressed: () {
                // Navigazione alla pagina di inserimento dei risultati
                Navigator.pushNamed(context, '/matchResult', arguments: playersWithNumbers);
              },
              child: const Text('Inserisci Risultati delle Partite'),
            ),
          ],
        ),
      ),
    );
  }
}
