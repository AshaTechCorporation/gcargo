import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String hintText;
  final List<String> items;
  final String? selectedValue;
  final void Function(String?) onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isError = selectedValue == null || selectedValue!.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: isError ? kTextRedWanningColor : kButtonColor)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: isError ? kTextRedWanningColor : Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(hintText, style: const TextStyle(color: kHintTextColor)),
              value: selectedValue,
              onChanged: onChanged,
              items:
                  items.map((item) {
                    return DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(color: Colors.black)));
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
