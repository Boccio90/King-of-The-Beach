import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const BeachVolleyballTournamentApp());
}

class BeachVolleyballTournamentApp extends StatelessWidget {
  const BeachVolleyballTournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beach Volleyball Tournament',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PlayersInputPage(),
        '/groupsDisplay': (context) => GroupsDisplayPage(
          playersWithNumbers: ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>,
        ),
        '/matchResult': (context) => MatchResultPage(
          playersWithNumbers: ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>,
        ),
        '/resultDisplay': (context) => ResultDisplayPage(
          results: ModalRoute.of(context)!.settings.arguments as List<Map<String, dynamic>>,
        ),
      },
    );
  }
}

class PlayersInputPage extends StatefulWidget {
  const PlayersInputPage({super.key});

  @override
  PlayersInputPageState createState() => PlayersInputPageState();
}

class PlayersInputPageState extends State<PlayersInputPage> {
  final List<TextEditingController> _controllers = List.generate(
    8,
    (index) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserisci Giocatori'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 0; i < 8; i++)
              TextField(
                controller: _controllers[i],
                decoration: InputDecoration(
                  labelText: 'Giocatore ${i + 1}',
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                List<String> players = _controllers.map((c) => c.text).toList();
                Navigator.pushNamed(
                  context,
                  '/groupsDisplay',
                  arguments: _assignNumbers(players),
                );
              },
              child: const Text('Assegna Numeri'),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _assignNumbers(List<String> players) {
    final random = Random();
    List<int> numbers = List.generate(8, (index) => index + 1);
    numbers.shuffle(random);

    return players.asMap().entries.map((entry) {
      return {
        'name': entry.value,
        'number': numbers[entry.key],
      };
    }).toList();
  }
}

class GroupsDisplayPage extends StatelessWidget {
  final List<Map<String, dynamic>> playersWithNumbers;

  const GroupsDisplayPage({super.key, required this.playersWithNumbers});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> oddGroup = playersWithNumbers.where((p) => p['number'] % 2 != 0).toList();
    List<Map<String, dynamic>> evenGroup = playersWithNumbers.where((p) => p['number'] % 2 == 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gruppi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Gruppo Dispari:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var player in oddGroup)
              Text('${player['name']} - Numero ${player['number']}'),
            const SizedBox(height: 20),
            const Text('Gruppo Pari:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var player in evenGroup)
              Text('${player['name']} - Numero ${player['number']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/matchResult', arguments: playersWithNumbers);
              },
              child: const Text('Mostra Risultato Partita'),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchResultPage extends StatefulWidget {
  final List<Map<String, dynamic>> playersWithNumbers;

  const MatchResultPage({super.key, required this.playersWithNumbers});

  @override
  MatchResultPageState createState() => MatchResultPageState();
}

class MatchResultPageState extends State<MatchResultPage> {
  final List<TextEditingController> _team1Controllers = [];
  final List<TextEditingController> _team2Controllers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 3; i++) {
      _team1Controllers.add(TextEditingController());
      _team2Controllers.add(TextEditingController());
    }
  }

  List<List<Map<String, dynamic>>> _createMatches(List<Map<String, dynamic>> players) {
    return [
      [
        players[0],
        players[1],
        players[2],
        players[3],
      ],
      [
        players[4],
        players[5],
        players[6],
        players[7],
      ],
      [
        players[0],
        players[3],
        players[4],
        players[7],
      ],
    ];
  }

  void _saveResults() {
    List<Map<String, dynamic>> results = [];
    for (int i = 0; i < 3; i++) {
      int team1Score = int.parse(_team1Controllers[i].text);
      int team2Score = int.parse(_team2Controllers[i].text);
      var match = _createMatches(widget.playersWithNumbers)[i];

      for (var player in [match[0], match[1]]) {
        results.add({
          'name': player['name'],
          'win': team1Score > team2Score ? 1 : 0,
          'pointsDiff': team1Score - team2Score,
        });
      }

      for (var player in [match[2], match[3]]) {
        results.add({
          'name': player['name'],
          'win': team1Score < team2Score ? 1 : 0,
          'pointsDiff': team2Score - team1Score,
        });
      }
    }
    Navigator.pushNamed(context, '/resultDisplay', arguments: results);
  }

  @override
  Widget build(BuildContext context) {
    List<List<Map<String, dynamic>>> matches = _createMatches(widget.playersWithNumbers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risultato Partita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 0; i < matches.length; i++)
              Row(
                children: [
                  Expanded(
                    child: Text('${matches[i][0]['name']} e ${matches[i][1]['name']}'),
                  ),
                  const Text(' VS '),
                  Expanded(
                    child: Text('${matches[i][2]['name']} e ${matches[i][3]['name']}'),
                  ),
                  SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _team1Controllers[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0',
                      ),
                    ),
                  ),
                  const Text(' - '),
                  SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _team2Controllers[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0',
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveResults,
              child: const Text('Salva Risultati'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultDisplayPage extends StatelessWidget {
  final List<Map<String, dynamic>> results;

  const ResultDisplayPage({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> playerResults = {};

    for (var result in results) {
      if (!playerResults.containsKey(result['name'])) {
        playerResults[result['name']] = {'wins': 0, 'pointsDiff': 0};
      }
      playerResults[result['name']]!['wins'] += result['win'];
      playerResults[result['name']]!['pointsDiff'] += result['pointsDiff'];
    }

    final sortedResults = playerResults.entries.toList()
      ..sort((a, b) => b.value['wins'].compareTo(a.value['wins']));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classifica Finale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Classifica:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var entry in sortedResults)
              Text('${entry.key}: ${entry.value['wins']} vittorie, differenza punti: ${entry.value['pointsDiff']}'),
          ],
        ),
      ),
    );
  }
}
