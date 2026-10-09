import 'package:flutter/material.dart';
import '../../app/theme.dart';

class StyledDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const StyledDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SpinColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          isExpanded: true,
          itemHeight: null,
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(),
          icon: const Icon(Icons.expand_more, color: SpinColors.navyDark),
        ),
      ],
    );
  }
}
