import 'package:flutter/material.dart';
import '../widgets/page_scaffold.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: title,
      child: const Center(
        child: Text(
          'Coming soon',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
