import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const DanceApp());
}

class DanceApp extends StatelessWidget {
  const DanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tanssilajitunnistus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DanceHomePage(),
    );
  }
}

class DanceHomePage extends StatefulWidget {
  const DanceHomePage({super.key});

  @override
  State<DanceHomePage> createState() => _DanceHomePageState();
}

class _DanceHomePageState extends State<DanceHomePage> {
  List<dynamic> clips = [];
  Map<String, dynamic>? currentClip;
  final player = AudioPlayer();
  String resultText = "";

  final List<String> styles = [
    "fusku",
    "bugg",
    "tango",
    "valssi",
  ];

  @override
  void initState() {
    super.initState();
    loadClips();
  }

  Future<void> loadClips() async {
    print("Loading clips.json...");
    print("Loaded clips: $clips");
    final jsonString = await rootBundle.loadString('assets/audio/clips.json');
    final data = json.decode(jsonString);

    setState(() {
      clips = data;
    });
  }

  void pickRandomClip() {
    if (clips.isEmpty) return;

    final random = Random();
    final index = random.nextInt(clips.length);

    setState(() {
      currentClip = clips[index];
      resultText = "";
    });

    playClip(currentClip!['file']);
  }

  Future<void> playClip(String filePath) async {
  await player.stop();
  await player.play(
    AssetSource('audio/$filePath'),
  );
  }

  void checkAnswer(String answer) {
    if (currentClip == null) return;

    final correct = currentClip!['style'];

    setState(() {
      if (answer == correct) {
        resultText = "Oikein! 🎉";
      } else {
        resultText = "Väärin. Oikea vastaus: $correct";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tanssilajitunnistus"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickRandomClip,
              child: const Text("Soita satunnainen klippi"),
            ),
            const SizedBox(height: 20),

            // Vastausnapit
            Wrap(
              spacing: 10,
              children: styles.map((style) {
                return ElevatedButton(
                  onPressed: () => checkAnswer(style),
                  child: Text(style),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            Text(
              resultText,
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}