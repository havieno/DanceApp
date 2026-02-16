import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

void main() {
  runApp(const DanceApp());
}

class DanceApp extends StatelessWidget {
  const DanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tanssilajitunnistus',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  final AudioPlayer player = AudioPlayer();
  List<dynamic> clips = [];
  Map<String, dynamic>? currentClip;

  int score = 0;
  int total = 0;
  String feedback = "";

  @override
  void initState() {
    super.initState();
    loadClips();
  }

  Future<void> loadClips() async {
    final String jsonString =
        await rootBundle.loadString('assets/audio/clips.json');
    setState(() {
      clips = json.decode(jsonString);
    });
  }

  Future<void> playRandomClip() async {
    if (clips.isEmpty) return;

    final random = Random();
    final clip = clips[random.nextInt(clips.length)];

    setState(() {
      currentClip = clip;
      feedback = "";
    });

    await playClip(clip['file']);
  }

  Future<void> playClip(String filePath) async {
    await player.stop();
    await player.play(
      AssetSource('audio/$filePath'),
    );
  }

  void checkAnswer(String userAnswer) {
    if (currentClip == null) return;

    setState(() {
      total++;

      if (userAnswer == currentClip!['style']) {
        score++;
        feedback = "Oikein!";
      } else {
        feedback = "Väärin!";
      }
    });
  }

  void resetScore() {
    setState(() {
      score = 0;
      total = 0;
      feedback = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tanssilajitunnistus"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Pisteet: $score / $total",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              feedback,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: playRandomClip,
              child: const Text("Soita satunnainen klippi"),
            ),

            const SizedBox(height: 30),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => checkAnswer("fusku"),
                  child: const Text("Fusku"),
                ),
                ElevatedButton(
                  onPressed: () => checkAnswer("bugg"),
                  child: const Text("Bugg"),
                ),
                ElevatedButton(
                  onPressed: () => checkAnswer("tango"),
                  child: const Text("Tango"),
                ),
                ElevatedButton(
                  onPressed: () => checkAnswer("valssi"),
                  child: const Text("Valssi"),
                ),
              ],
            ),

            const SizedBox(height: 30),


// 🔽 TÄHÄN LISÄTÄÄN STOP + END 🔽

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: () async {
        await player.stop();
        setState(() {
          feedback = "Keskeytetty";
        });
      },
      child: const Text("Stop"),
    ),
    const SizedBox(width: 20),
    ElevatedButton(
      onPressed: () {
        SystemNavigator.pop();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text("End"),
    ),
  ],
),

const SizedBox(height: 20),

// 🔼 STOP + END LOPPUU TÄHÄN 🔼


            ElevatedButton(
              onPressed: resetScore,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Nollaa pisteet"),
            ),
          ],
        ),
      ),
    );
  }
}