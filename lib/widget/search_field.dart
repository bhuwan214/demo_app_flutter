import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final Color? fillColor;
  final Color? iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const SearchTextField({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.fillColor,
    this.iconColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          fillColor: fillColor ?? colorScheme.surface,
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            color: iconColor,
          ),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              return value.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: iconColor,
                      ),
                      onPressed: () {
                        controller.clear();
                        if (onClear != null) {
                          onClear!();
                        }
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}