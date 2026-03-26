import 'package:flutter/material.dart';

class RoadmapScreen extends StatelessWidget {
  final List<String> roadmapSteps;

  RoadmapScreen({
    super.key,
    this.roadmapSteps = const [
      'Step 1: Learn Python',
      'Step 2: Learn Flutter',
      'Step 3: Build Project',
      'Step 4: Deploy App',
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Roadmap')),
      body: ListView.builder(
        itemCount: roadmapSteps.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                roadmapSteps[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
