import 'package:flutter/material.dart';

// EXAMPLE FEATURE
// Each team member should create their own file like this one.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tourism App Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to the Tourism App!"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to another feature
                // Navigator.pushNamed(context, '/tours');
              },
              child: const Text("Explore Tours"),
            )
          ],
        ),
      ),
    );
  }
}
