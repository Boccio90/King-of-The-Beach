import 'dart:math';
import 'package:flutter/material.dart';

class NumberAssignmentPage extends StatelessWidget {
  const NumberAssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> players = ModalRoute.of(context)!.settings.arguments as List<String>;

    // Genera numeri casuali univoci da 1 a 8
    List<int> assignedNumbers = List.generate(8, (index) => index + 1)..shuffle(Random());

    // Crea una mappa tra giocatori e numeri assegnati
    Map<String, int> playerNumbers = {
      for (int i = 0; i < players.length; i++) players[i]: assignedNumbers[i]
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Assegna Numeri')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...playerNumbers.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                trailing: Text('Numero: ${entry.value}'),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/groupsDisplay', arguments: playerNumbers);
              },
              child: const Text('Visualizza Gironi'),
            ),
          ],
        ),
      ),
    );
  }
}
