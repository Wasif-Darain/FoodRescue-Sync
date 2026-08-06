import 'package:flutter/material.dart';

const kFieldRowBreakpoint = 420.0;

class AppFormField extends StatelessWidget {
  final String label;
  final String value;
  final bool readOnly;
  final bool obscure;
  final String? placeholder;
  const AppFormField({
    super.key,
    required this.label,
    required this.value,
    this.readOnly = false,
    this.obscure = false,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          readOnly: readOnly,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFBFBFBF), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: readOnly,
            fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2),
            ),
          ),
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
        ),
      ],
    );
  }
}

class AppFormFieldRow extends StatelessWidget {
  final List<Widget> children;

  const AppFormFieldRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kFieldRowBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index < children.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }
}