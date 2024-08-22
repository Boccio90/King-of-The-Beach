import 'package:flutter/material.dart';

class PlayersInputPage extends StatefulWidget {
  const PlayersInputPage({super.key});

  @override
  PlayersInputPageState createState() => PlayersInputPageState();
}

class PlayersInputPageState extends State<PlayersInputPage> {
  final List<TextEditingController> _controllers = List.generate(8, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inserisci Giocatori')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...List.generate(8, (index) {
              return TextField(
                controller: _controllers[index],
                decoration: InputDecoration(labelText: 'Giocatore ${index + 1}'),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                List<String> players = _controllers.map((controller) => controller.text).toList();
                Navigator.pushNamed(context, '/numberAssignment', arguments: players);
              },
              child: const Text('Avanti'),
            ),
          ],
        ),
      ),
    );
  }
}
