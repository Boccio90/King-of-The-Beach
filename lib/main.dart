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
          oddResults: (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['oddResults'] as List<Map<String, dynamic>>,
          evenResults: (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['evenResults'] as List<Map<String, dynamic>>,
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
                List<String> players = _controllers.map((c) => c.text.trim()).toList();

                // Verifica che ci siano esattamente 8 giocatori e nessun nome vuoto
                if (players.any((player) => player.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tutti i campi devono essere compilati.')),
                  );
                  return;
                }

                // Verifica che i nomi dei giocatori siano unici
                if (players.toSet().length != players.length) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('I nomi dei giocatori devono essere unici.')),
                  );
                  return;
                }

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
    List<Map<String, dynamic>> oddGroup = playersWithNumbers.where((player) => player['number'] % 2 != 0).toList();
    List<Map<String, dynamic>> evenGroup = playersWithNumbers.where((player) => player['number'] % 2 == 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gruppi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Gruppo Dispari:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var player in oddGroup) Text('${player['number']}: ${player['name']}'),
            const SizedBox(height: 20),
            const Text('Gruppo Pari:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var player in evenGroup) Text('${player['number']}: ${player['name']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/matchResult',
                  arguments: playersWithNumbers,
                );
              },
              child: const Text('Vai alla Pagina dei Risultati'),
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
    List<Map<String, dynamic>> matches = [
      {'team1': [players[0], players[2]], 'team2': [players[4], players[6]]},  // Girone dispari
      {'team1': [players[0], players[4]], 'team2': [players[2], players[6]]},  
      {'team1': [players[0], players[6]], 'team2': [players[2], players[4]]},  
      {'team1': [players[1], players[3]], 'team2': [players[5], players[7]]},  // Girone pari
      {'team1': [players[1], players[5]], 'team2': [players[3], players[7]]},  
      {'team1': [players[1], players[7]], 'team2': [players[3], players[5]]},  
    ];
    return matches;
  }

  void _saveResults() {
    List<Map<String, dynamic>> oddResults = [];
    List<Map<String, dynamic>> evenResults = [];
    List<Map<String, dynamic>> matchPairs = _generateMatchPairs(widget.playersWithNumbers);

    for (int i = 0; i < 3; i++) {
      int team1Score = int.tryParse(_team1Controllers[i].text) ?? 0;
      int team2Score = int.tryParse(_team2Controllers[i].text) ?? 0;

      for (var player in matchPairs[i]['team1']) {
        oddResults.add({
          'name': player['name'],
          'win': team1Score > team2Score ? 1 : 0,
          'pointsDiff': team1Score - team2Score,
        });
      }

      for (var player in matchPairs[i]['team2']) {
        oddResults.add({
          'name': player['name'],
          'win': team2Score > team1Score ? 1 : 0,
          'pointsDiff': team2Score - team1Score,
        });
      }
    }

    for (int i = 3; i < 6; i++) {
      int team1Score = int.tryParse(_team1Controllers[i].text) ?? 0;
      int team2Score = int.tryParse(_team2Controllers[i].text) ?? 0;

      for (var player in matchPairs[i]['team1']) {
        evenResults.add({
          'name': player['name'],
          'win': team1Score > team2Score ? 1 : 0,
          'pointsDiff': team1Score - team2Score,
        });
      }

      for (var player in matchPairs[i]['team2']) {
        evenResults.add({
          'name': player['name'],
          'win': team2Score > team1Score ? 1 : 0,
          'pointsDiff': team2Score - team1Score,
        });
      }
    }

    Navigator.pushNamed(context, '/resultDisplay', arguments: {
      'oddResults': oddResults,
      'evenResults': evenResults,
    });
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
            for (int i = 0; i < matchPairs.length; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                        '${matchPairs[i]['team1'][0]['number']} ${matchPairs[i]['team1'][0]['name']} '
                        'e ${matchPairs[i]['team1'][1]['number']} ${matchPairs[i]['team1'][1]['name']} '
                        'vs ${matchPairs[i]['team2'][0]['number']} ${matchPairs[i]['team2'][0]['name']} '
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
              child: const Text('Salva Risultati'),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultDisplayPage extends StatelessWidget {
  final List<Map<String, dynamic>> oddResults;
  final List<Map<String, dynamic>> evenResults;

  const ResultDisplayPage({
    super.key,
    required this.oddResults,
    required this.evenResults,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Risultati Finali'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Risultati Gruppo Dispari:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._buildResultWidgets(oddResults),
            const SizedBox(height: 20),
            const Text('Risultati Gruppo Pari:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._buildResultWidgets(evenResults),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultWidgets(List<Map<String, dynamic>> results) {
    return results.map((result) {
      return Text(
        '${result['name']}: Vittorie = ${result['win']}, Differenza punti = ${result['pointsDiff']}',
      );
    }).toList();
  }
}
