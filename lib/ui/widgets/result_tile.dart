import 'package:flutter/material.dart';
import '../../app/theme.dart';

class ResultTile extends StatelessWidget {
  final String label;
  final String? value;
  final bool highlight;

  const ResultTile({
    super.key,
    required this.label,
    this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SpinColors.lavenderLight, SpinColors.cardWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: highlight ? Border.all(color: SpinColors.amber, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: SpinColors.navyDark,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            (value == null || value!.isEmpty) ? '-' : value!,
            style: const TextStyle(
              color: SpinColors.navyDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
