import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomInputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const CustomInputField({
    super.key,
    required this.hint,
    required this.icon,
    this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: AppTheme.textSecondaryColor,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }
}
