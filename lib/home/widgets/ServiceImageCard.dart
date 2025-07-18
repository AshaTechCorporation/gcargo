import 'package:flutter/material.dart';

class ServiceImageCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const ServiceImageCard({super.key, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(imagePath, height: 100, fit: BoxFit.fill)),
      ),
    );
  }
}
