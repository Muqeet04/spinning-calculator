import 'package:flutter/material.dart';
import '../../app/theme.dart';

class InputCard extends StatelessWidget {
  final String title;
  final Widget child;

  const InputCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SpinColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: SpinColors.amber, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SpinColors.navyDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 24),
            width: 40,
            height: 3,
            color: SpinColors.amber,
          ),
          child,
        ],
      ),
    );
  }
}
