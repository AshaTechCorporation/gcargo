import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(DateTimeRange?)? onDateRangeSelected;

  const DateRangePickerWidget({
    super.key,
    required this.controller,
    this.hintText = 'เลือกช่วงวันที่',
    this.onDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          DateTimeRange? picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2023),
            lastDate: DateTime(2030),
            initialDateRange: DateTimeRange(
              start: DateTime(2024, 1, 1), 
              end: DateTime(2025, 7, 1)
            ),
          );
          
          if (picked != null) {
            String formatted = '${DateFormat('dd/MM/yyyy').format(picked.start)} - ${DateFormat('dd/MM/yyyy').format(picked.end)}';
            controller.text = formatted;
            
            // Callback เมื่อเลือกวันที่
            if (onDateRangeSelected != null) {
              onDateRangeSelected!(picked);
            }
          }
        },
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0), 
            child: Image.asset('assets/icons/calendar_icon.png', width: 18)
          ),
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
