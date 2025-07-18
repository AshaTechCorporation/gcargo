import 'package:flutter/material.dart';
import 'package:gcargo/login/securitySettingsPage.dart';

class PinEntryPage extends StatefulWidget {
  const PinEntryPage({super.key});

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage> {
  List<String> _pin = [];

  void _onKeyPressed(String value) {
    if (_pin.length < 6) {
      setState(() {
        _pin.add(value);
      });
      if (_pin.length == 6) {
        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsPage()));
        });
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.arrow_back_ios, size: 20),
              const SizedBox(height: 16),
              const Text('รหัส PIN', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('สมัครใช้งานง่าย ส่งของจากจีนถึงไทยสบายใจทุกขั้นตอน', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 32),
              const Text('โปรดยืนยัน PIN เพื่อเข้าสู่ระบบ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              const Text(
                'ใช้สำหรับอุปกรณ์นี้เพื่อหลีกเลี่ยงการป้อนรหัสผ่านทุกครั้งที่เข้าสู่ระบบ',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => Container(
                    width: 44,
                    height: 48,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: Text(index < _pin.length ? '●' : '', style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(8),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: size.width / (size.height / 2.2),
                  children: [
                    ...List.generate(9, (index) {
                      final digit = (index + 1).toString();
                      return _buildKey(digit);
                    }),
                    const SizedBox(), // blank space
                    _buildKey('0'),
                    _buildBackspaceKey(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String digit) {
    return GestureDetector(
      onTap: () => _onKeyPressed(digit),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade100),
        alignment: Alignment.center,
        child: Text(digit, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade100),
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined),
      ),
    );
  }
}
