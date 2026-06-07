import 'package:flutter/material.dart';

/// Reusable dropdown form field.
class XDropdownField<T> extends StatelessWidget {
  const XDropdownField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      isExpanded: true,
    );
  }
}
