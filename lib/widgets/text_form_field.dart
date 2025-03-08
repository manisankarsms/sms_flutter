import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final int maxLines; // Add maxLines parameter

  const CustomTextFormField({
    Key? key,
    required this.label,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1, // Default to 1 for single-line input
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      maxLines: maxLines, // Allow multi-line input
    );
  }
}
