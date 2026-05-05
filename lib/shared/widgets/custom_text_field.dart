import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: colorScheme.secondary.withAlpha(
          76,
        ), // 0.3 alpha -> 255 * 0.3 = 76.5
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}
