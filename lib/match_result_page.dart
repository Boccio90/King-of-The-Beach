import 'package:flutter/material.dart';

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
    List<Map<String, dynamic>> results = [];
    List<Map<String, dynamic>> matchPairs = _generateMatchPairs(widget.playersWithNumbers);

    for (int i = 0; i < matchPairs.length; i++) {
      int team1Score = int.tryParse(_team1Controllers[i].text) ?? 0;
      int team2Score = int.tryParse(_team2Controllers[i].text) ?? 0;

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
              child: const Text('Salva Risultati'),
            ),
          ],
        ),
      ),
    );
  }
}
