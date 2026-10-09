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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? SpinColors.emeraldGlow : SpinColors.coolGreyBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? SpinColors.emerald : SpinColors.borderLight,
          width: highlight ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: highlight ? SpinColors.emerald : SpinColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (value == null || value!.isEmpty) ? '-' : value!,
            style: TextStyle(
              color: highlight ? const Color(0xFF065F46) : SpinColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
