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
    for (var i = 0; i < 6; i++) {
      _team1Controllers.add(TextEditingController());
      _team2Controllers.add(TextEditingController());
    }
  }

  List<Map<String, dynamic>> _generateMatchPairs(List<Map<String, dynamic>> players) {
    // Creiamo le partite come richiesto
    List<Map<String, dynamic>> matches = [
      // Girone Dispari
      {'team1': [players[0], players[2]], 'team2': [players[4], players[6]]},  // 1 e 3 vs 5 e 7
      {'team1': [players[0], players[4]], 'team2': [players[2], players[6]]},  // 1 e 5 vs 3 e 7
      {'team1': [players[0], players[6]], 'team2': [players[2], players[4]]},  // 1 e 7 vs 3 e 5
      
      // Girone Pari
      {'team1': [players[1], players[3]], 'team2': [players[5], players[7]]},  // 2 e 4 vs 6 e 8
      {'team1': [players[1], players[5]], 'team2': [players[3], players[7]]},  // 2 e 6 vs 4 e 8
      {'team1': [players[1], players[7]], 'team2': [players[3], players[5]]},  // 2 e 8 vs 4 e 6
    ];
    return matches;
  }

  void _saveResults() {
    List<Map<String, dynamic>> results = [];
    List<Map<String, dynamic>> matchPairs = _generateMatchPairs(widget.playersWithNumbers);

    for (int i = 0; i < matchPairs.length; i++) {
      int team1Score = int.parse(_team1Controllers[i].text);
      int team2Score = int.parse(_team2Controllers[i].text);

      for (var player in matchPairs[i]['team1']) {
        results.add({
          'name': player['name'],
          'win': team1Score > team2Score ? 1 : 0,
          'pointsDiff': team1Score - team2Score,
        });
      }

      for (var player in matchPairs[i]['team2']) {
        results.add({
          'name': player['name'],
          'win': team2Score > team1Score ? 1 : 0,
          'pointsDiff': team2Score - team1Score,
        });
      }
    }

    Navigator.pushNamed(context, '/resultDisplay', arguments: results);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> matchPairs = _generateMatchPairs(widget.playersWithNumbers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risultato Partite'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Girone Dispari:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (int i = 0; i < 3; i++)
              Row(
                children: [
                  Expanded(
                    child: Text('${matchPairs[i]['team1'][0]['number']} ${matchPairs[i]['team1'][0]['name']} '
                        'e ${matchPairs[i]['team1'][1]['number']} ${matchPairs[i]['team1'][1]['name']}'),
                  ),
                  const Text(' VS '),
                  Expanded(
                    child: Text('${matchPairs[i]['team2'][0]['number']} ${matchPairs[i]['team2'][0]['name']} '
                        'e ${matchPairs[i]['team2'][1]['number']} ${matchPairs[i]['team2'][1]['name']}'),
                  ),
                  SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _team1Controllers[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '0'),
                    ),
                  ),
                  const Text('-'),
                  SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _team2Controllers[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '0'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Text('Girone Pari:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (int i = 3; i < 6; i++)
              Row(
                children: [
                  Expanded(
                    child: Text('${matchPairs[i]['team1'][0]['number']} ${matchPairs[i]['team1'][0]['name']} '
                        'e ${matchPairs[i]['team1'][1]['number']} ${matchPairs[i]['team1'][1]['name']}'),
                  ),
                  const Text(' VS '),
                  Expanded(
                    child: Text('${matchPairs[i]['team2'][0]['number']} ${matchPairs[i]['team2'][0]['name']} '
                        'e ${matchPairs[i]['team2'][1]['number']} ${matchPairs[i]['team2'][1]['name']}'),
                  ),
                  SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _team1Controllers[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '0'),
                    ),
                  ),
                  const Text('-'),
                  SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _team2Controllers[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '0'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveResults,
              child: const Text('Calcola Risultati'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risultati'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (var result in results)
              Text(
                '${result['name']}: Vittorie: ${result['win']}, Differenza Punti: ${result['pointsDiff']}',
              ),
          ],
        ),
      ),
    );
  }
}
