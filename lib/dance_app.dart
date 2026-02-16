import 'package:flutter/material.dart';

class DanceApp extends StatelessWidget {
  const DanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dance App'),
        ),
        body: const Center(
          child: Text(
            'Dance App toimii!',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
