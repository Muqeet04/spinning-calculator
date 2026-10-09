import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';

class StyledTextField extends StatelessWidget {
  final String label;
  final ValueChanged<String>? onChanged;
  final bool isNumber;
  final String? errorText;
  final TextEditingController? controller;

  const StyledTextField({
    super.key,
    required this.label,
    this.onChanged,
    this.isNumber = false,
    this.errorText,
    this.controller,
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
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
              : null,
          decoration: InputDecoration(
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}
