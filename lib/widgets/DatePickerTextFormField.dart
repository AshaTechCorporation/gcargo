import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:intl/intl.dart';

class DatePickerTextFormField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool isRequired;

  const DatePickerTextFormField({super.key, required this.label, required this.hintText, required this.controller, this.isRequired = true});

  @override
  State<DatePickerTextFormField> createState() => _DatePickerTextFormFieldState();
}

class _DatePickerTextFormFieldState extends State<DatePickerTextFormField> {
  DateTime? selectedDate;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        widget.controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isError = widget.isRequired && widget.controller.text.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 16, color: isError ? kTextRedWanningColor : kButtonColor)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: AbsorbPointer(
            child: TextFormField(
              controller: widget.controller,
              validator: (value) {
                if (widget.isRequired && (value == null || value.trim().isEmpty)) {
                  return 'กรุณากรอก${widget.label}';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: kHintTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: isError ? kTextRedWanningColor : Colors.grey),
                ),
                suffixIcon: const Icon(Icons.calendar_today, color: kHintTextColor),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
