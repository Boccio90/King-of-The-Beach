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
                List<String> players = _controllers.map((c) => c.text).toList();

                // Verifica che ci siano esattamente 8 giocatori e nessun nome vuoto
                if (players.length != 8 || players.any((player) => player.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Devi inserire esattamente 8 giocatori.')),
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
    // Dividi i giocatori in due gruppi: dispari e pari
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
            _buildPlayerList(oddGroup),
            const SizedBox(height: 20),
            const Text('Gruppo Pari:', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildPlayerList(evenGroup),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/matchResult', arguments: playersWithNumbers);
              },
              child: const Text('Inserisci Risultati'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerList(List<Map<String, dynamic>> group) {
    return Column(
      children: group.map((player) {
        return ListTile(
          title: Text('${player['number']} - ${player['name']}'),
        );
      }).toList(),
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
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (var _ in widget.playersWithNumbers) {
      _controllers.add(TextEditingController());
    }
  }

  void _calculateResults(List<Map<String, dynamic>> oddGroup, List<Map<String, dynamic>> evenGroup) {
    List<Map<String, dynamic>> oddResults = _calculateGroupResults(oddGroup);
    List<Map<String, dynamic>> evenResults = _calculateGroupResults(evenGroup);

    Navigator.pushNamed(
      context,
      '/resultDisplay',
      arguments: {'oddResults': oddResults, 'evenResults': evenResults},
    );
  }

  List<Map<String, dynamic>> _calculateGroupResults(List<Map<String, dynamic>> group) {
    List<Map<String, dynamic>> results = [];

    // Placeholder logic for results calculation
    for (var player in group) {
      results.add({
        'name': player['name'],
        'wins': Random().nextInt(3),  // Placeholder: Replace with real calculation
        'pointsDiff': Random().nextInt(20) - 10,  // Placeholder: Replace with real calculation
      });
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> oddGroup = widget.playersWithNumbers.where((p) => p['number'] % 2 != 0).toList();
    List<Map<String, dynamic>> evenGroup = widget.playersWithNumbers.where((p) => p['number'] % 2 == 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Risultato Partite'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Girone Dispari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              _buildMatches(oddGroup),
              const SizedBox(height: 20),
              const Text('Girone Pari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              _buildMatches(evenGroup),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _calculateResults(oddGroup, evenGroup),
                child: const Text('Calcola Risultati'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatches(List<Map<String, dynamic>> group) {
    return Column(
      children: [
        for (int i = 0; i < group.length; i++)
          TextField(
            controller: _controllers[i],
            decoration: InputDecoration(labelText: group[i]['name']),
            keyboardType: TextInputType.number,
          ),
      ],
    );
  }
}

class ResultDisplayPage extends StatelessWidget {
  final List<Map<String, dynamic>> oddResults;
  final List<Map<String, dynamic>> evenResults;

  const ResultDisplayPage({super.key, required this.oddResults, required this.evenResults});

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
            const Text('Risultati Girone Dispari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ..._buildResultList(oddResults),
            const SizedBox(height: 20),
            const Text('Risultati Girone Pari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ..._buildResultList(evenResults),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultList(List<Map<String, dynamic>> results) {
    return results.map((result) {
      return Text('${result['name']}: Vittorie ${result['wins']}, Differenza punti ${result['pointsDiff']}');
    }).toList();
  }
}
