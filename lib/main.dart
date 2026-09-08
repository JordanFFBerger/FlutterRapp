import 'package:flutter/material.dart';

void main() {
  runApp(const SingleButtonApp());
}

class SingleButtonApp extends StatelessWidget {
  const SingleButtonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Single Button',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SingleButtonPage(),
    );
  }
}

class SingleButtonPage extends StatelessWidget {
  const SingleButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () {},
          child: const Text('Button'),
        ),
      ),
    );
  }
}
