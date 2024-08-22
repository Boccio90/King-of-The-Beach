import 'package:flutter/material.dart';

class Player {
  final String name;
  final int win;
  final int pointsDiff;

  Player({
    required this.name,
    required this.win,
    required this.pointsDiff,
  });
}

class ResultDisplayPage extends StatelessWidget {
  final List<Player> evenGroupResults;
  final List<Player> oddGroupResults;

  const ResultDisplayPage({super.key, 
    required this.evenGroupResults,
    required this.oddGroupResults,
  });

  List<Player> _getAggregatedResults() {
    List<Player> aggregatedResults = [];
    aggregatedResults.addAll(evenGroupResults);
    aggregatedResults.addAll(oddGroupResults);

    // Ordina i risultati aggregati in base al numero di vittorie e alla differenza punti
    aggregatedResults.sort((a, b) {
      // Prima ordina per vittorie in ordine decrescente
      int winComparison = b.win.compareTo(a.win);
      if (winComparison != 0) {
        return winComparison;
      }
      // Se le vittorie sono uguali, ordina per differenza punti in ordine decrescente
      return b.pointsDiff.compareTo(a.pointsDiff);
    });

    return aggregatedResults;
  }

  @override
  Widget build(BuildContext context) {
    List<Player> aggregatedResults = _getAggregatedResults();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Risultati Aggregati'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pari'),
              Tab(text: 'Dispari'),
              Tab(text: 'Aggregati'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildResultList(evenGroupResults, 'Gruppo Pari'),
            _buildResultList(oddGroupResults, 'Gruppo Dispari'),
            _buildResultList(aggregatedResults, 'Risultati Aggregati'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultList(List<Player> players, String title) {
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        Player player = players[index];
        // Formattazione del testo per mostrare il nome del giocatore, vittorie e differenza punti
        String playerInfo =
            '${player.name}: ${player.win} Vittoria${player.win == 1 ? '' : 'e'} - Diff. punti ${player.pointsDiff}';
        return ListTile(
          title: Text(playerInfo),
        );
      },
    );
  }
}
