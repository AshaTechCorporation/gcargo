import 'package:flutter/material.dart';

class ChangePinPage extends StatefulWidget {
  const ChangePinPage({super.key});

  @override
  State<ChangePinPage> createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  List<String> _pin = [];

  void _onKeyPressed(String value) {
    if (_pin.length < 6) {
      setState(() {
        _pin.add(value);
      });
      if (_pin.length == 6) {
        // Future.delayed(const Duration(milliseconds: 200), () {
        //   Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsPage()));
        // });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('เปลี่ยนรหัส PIN', style: TextStyle(fontSize: 16, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.08),
            const Text('โปรดระบุ PIN เดิมที่ไว้เข้าสู่ระบบ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('ใช้สำหรับอุปกรณ์นี้เพื่อหลีกเลี่ยงการป้อนรหัสผ่านทุกครั้งที่เข้าสู่ระบบ', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 32),
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
