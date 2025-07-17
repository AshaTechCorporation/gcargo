import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final bool isRequired;
  final int maxLines;
  final TextInputType keyboardType;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isRequired = true,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    final isError = _showError && widget.controller.text.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 18, color: isError ? kTextRedWanningColor : kButtonColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          obscureText: widget.isPassword && _obscureText,
          style: const TextStyle(color: Colors.black),

          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: kHintTextColor),
            errorStyle: TextStyle(color: kTextRedWanningColor, fontSize: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isError ? kTextRedWanningColor : Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isError ? kTextRedWanningColor : Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isError ? kTextRedWanningColor : kButtonColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon:
                widget.isPassword
                    ? IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                    : null,
          ),
          validator: (value) {
            if (widget.isRequired && (value == null || value.isEmpty)) {
              setState(() => _showError = true);
              return 'กรุณากรอก${widget.label}';
            }
            setState(() => _showError = false);
            return null;
          },
        ),
      ],
    );
  }
}
