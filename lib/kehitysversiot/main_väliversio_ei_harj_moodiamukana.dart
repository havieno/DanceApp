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

  String? lastPlayedFile;     // ⭐ viimeksi soitettu klippi
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

  // ⭐ Arpoo uuden klipin, joka ei ole sama kuin viimeksi soitettu
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

  // ⭐ Toistaa viimeksi soitetun klipin
  Future<void> replayLastClip() async {
    if (lastPlayedFile == null) return;
    await playClip(lastPlayedFile!);
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

  void endApp() {
    if (Platform.isWindows) {
      exit(0);
    }
    SystemNavigator.pop();
  }

  // ⭐ Siisti, matala nappi
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 4.5,   // ⭐ matalammat napit
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
                  // Lisää halutessasi lisää tanssilajeja
                  danceButton("Cha-Cha", "cha-cha"),
                  danceButton("Jenkka", "jenkka"),
                  danceButton("Polkka", "polkka"),


                ],
              ),
            ),

            const SizedBox(height: 10),

            // ⭐ Keskeytä – Toista äskeinen – Lopeta
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
                  child: const Text("Keskeytä"),
                ),
                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: replayLastClip,
                  child: const Text("Toista äskeinen"),
                ),
                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: endApp,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Lopeta"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: resetScore,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Nollaa pisteet"),
            ),
          ],
        ),
      ),
    );
  }
}