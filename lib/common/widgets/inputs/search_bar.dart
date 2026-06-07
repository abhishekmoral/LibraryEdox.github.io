import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';

/// Reusable search bar widget.
class XSearchBar extends StatelessWidget {
  const XSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Iconsax.search_normal, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  controller.clear();
                  onClear?.call();
                },
                icon: const Icon(Icons.close, size: 20),
              )
            : null,
        filled: true,
        fillColor: dark ? XColors.darkCardBackground : XColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(XSizes.borderRadiusLg),
          borderSide: const BorderSide(color: XColors.primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: XSizes.md,
          vertical: XSizes.sm + 4,
        ),
      ),
    );
  }
}
