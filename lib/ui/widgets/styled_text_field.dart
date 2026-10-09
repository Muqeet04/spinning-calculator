import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';

class StyledTextField extends StatelessWidget {
  final String label;
  final ValueChanged<String>? onChanged;
  final bool isNumber;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool enabled;

  const StyledTextField({
    super.key,
    required this.label,
    this.onChanged,
    this.isNumber = false,
    this.errorText,
    this.controller,
    this.initialValue,
    this.keyboardType,
    this.enabled = true,
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
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          enabled: enabled,
          onChanged: onChanged,
          keyboardType: keyboardType ??
              (isNumber
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text),
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
