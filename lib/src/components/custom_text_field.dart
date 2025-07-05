import 'package:aru/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final Function()? onTap;
  final IconData? prefixIcon;
  final String? label;
  final TextStyle? labelStyle;
  final String? placeholder;
  final IconData? suffixIcon;
  final Function()? onSuffixIconTap;
  final bool obscureText;
  final bool readOnly;
  final bool outlined;
  final Color? fillColor;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? errorStyle;

  const CustomTextField({ 
    super.key, 
    this.controller,
    this.validator,
    this.focusNode,
    this.onTap,
    this.prefixIcon,
    this.label,
    this.labelStyle,
    this.placeholder,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.readOnly = false,
    this.outlined = false,
    this.fillColor,
    this.maxLines,
    this.inputFormatters,
    this.errorStyle
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      focusNode: focusNode,
      cursorColor: colorPrimary,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        filled: !outlined,
        fillColor: fillColor ?? colorPrimary.withValues(alpha: 0.05),
        hintText: label,
        hintStyle: labelStyle ?? TextStyle(
          color: Color(0xFF7C8BA0)
        ),
        suffixIcon: suffixIcon != null
          ? InkWell(
            splashFactory: NoSplash.splashFactory,
            focusNode: FocusNode(skipTraversal: true),
            onTap: onSuffixIconTap,
            child: Icon(suffixIcon),
          )
          : null,
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return Color(0xFF212121);
          }

          return Color(0xFF858585);
        }),
        errorStyle: errorStyle,
        enabledBorder: OutlineInputBorder(
          borderSide: outlined ? BorderSide(color: Color(0xFFD1D1D1)) : BorderSide.none,
          borderRadius: BorderRadius.circular(14)
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: readOnly ? BorderSide.none : BorderSide(color: colorPrimary),
          borderRadius: BorderRadius.circular(14)
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorRed),
          borderRadius: BorderRadius.circular(14)
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorRed),
          borderRadius: BorderRadius.circular(14)
        )
      ),
    );
  }
}