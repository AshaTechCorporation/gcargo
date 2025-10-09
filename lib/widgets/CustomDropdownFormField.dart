import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: isPhone(context) ? 18 : 22, color: kButtonColor)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          items: items,
          style: TextStyle(fontSize: isPhone(context) ? 18 : 22, color: Colors.black, fontFamily: 'SukhumvitSet'),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: kHintTextColor, fontSize: isPhone(context) ? 18 : 22),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kButtonColor)),
          ),
          icon: Icon(Icons.arrow_drop_down, color: kButtonColor, size: isPhone(context) ? 24 : 30),
        ),
      ],
    );
  }
}
