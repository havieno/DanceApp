import 'dart:convert';
import 'dart:io';
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

  String? lastPlayedFile;
  int score = 0;
  int total = 0;
  String feedback = "";

  bool trainingMode = false;

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
    Map<String, dynamic> clip;

    do {
      clip = clips[random.nextInt(clips.length)];
    } while (clip['file'] == lastPlayedFile && clips.length > 1);

    setState(() {
      currentClip = clip;
      lastPlayedFile = clip['file'];
      feedback = "";
    });

    await playClip(clip['file']);
  }

  Future<void> playClip(String filePath) async {
    await player.stop();
    await player.play(AssetSource('audio/$filePath'));
  }

  Future<void> replayLastClip() async {
    if (lastPlayedFile == null) return;
    await playClip(lastPlayedFile!);
  }

  void checkAnswer(String userAnswer) {
    if (currentClip == null) return;

    final correct = currentClip!['style'];

    if (trainingMode) {
      setState(() {
        if (userAnswer == correct) {
          feedback = "Oikein!";
        } else {
          feedback = "Väärin, yritä uudelleen";
        }
      });
      return;
    }

    setState(() {
      total++;
      if (userAnswer == correct) {
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

  void endApp() {
    if (Platform.isWindows) {
      exit(0);
    }
    SystemNavigator.pop();
  }

  Widget danceButton(String label, String style) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: () => checkAnswer(style),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget modeButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: active ? Colors.blue : Colors.grey,
        ),
        child: Text(label),
      ),
    );
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

            // ⭐ Testi / Harjoitus -painikkeet
            Row(
              children: [
                modeButton("Testi", !trainingMode, () {
                  setState(() {
                    trainingMode = false;
                    feedback = "";
                  });
                }),
                const SizedBox(width: 10),
                modeButton("Harjoitus", trainingMode, () {
                  setState(() {
                    trainingMode = true;
                    feedback = "";
                  });
                }),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: playRandomClip,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
              child: const Text("Soita satunnainen klippi"),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 4.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  danceButton("Fusku", "fusku"),
                  danceButton("Bugg", "bugg"),
                  danceButton("Valssi", "valssi"),
                  danceButton("Hidas Valssi", "hi-valssi"),
                  danceButton("Tango", "tango"),
                  danceButton("Rumba", "rumba"),
                  danceButton("Jive", "jive"),
                  danceButton("Salsa", "salsa"),
                  danceButton("Cha-Cha", "cha-cha"),
                  danceButton("Jenkka", "jenkka"),
                  danceButton("Polkka", "polkka"),
                ],
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

            if (!trainingMode)
              Text(
                "Pisteet: $score / $total",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await player.stop();
                      setState(() {
                        feedback = "Keskeytetty";
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                    child: const Text("Keskeytä"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: replayLastClip,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
                    child: const Text("Toista"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: resetScore,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text("Nollaa"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: endApp,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Lopeta"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}