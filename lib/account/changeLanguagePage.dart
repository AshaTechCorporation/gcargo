import 'package:flutter/material.dart';

class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({super.key});

  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  String selectedLang = 'ไทย';

  final List<String> languages = ['ไทย', 'จีน', 'อังกฤษ'];

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF002D65);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('เปลี่ยนภาษา', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: languages.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final lang = languages[index];
                return ListTile(
                  title: Text(lang),
                  trailing: Radio<String>(
                    value: lang,
                    groupValue: selectedLang,
                    onChanged: (value) => setState(() => selectedLang = value!),
                    activeColor: themeColor,
                  ),
                  onTap: () => setState(() => selectedLang = lang),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // TODO: เปลี่ยนภาษา
                },
                child: const Text('ยืนยัน', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
