import 'package:flutter/material.dart';

class HtmlTextWidget extends StatelessWidget {
  final String htmlContent;

  const HtmlTextWidget({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    // แปลง HTML เป็น text ธรรมดา (ลบ tags ออก)
    final plainText = _stripHtmlTags(htmlContent);

    return Text(plainText, style: const TextStyle(fontSize: 14, height: 1.6));
  }

  String _stripHtmlTags(String htmlString) {
    String result = htmlString;

    // แปลง closing tags เป็น line break ก่อน
    result = result.replaceAll('</p>', '\n\n');
    result = result.replaceAll('</div>', '\n');
    result = result.replaceAll('</li>', '\n');
    result = result.replaceAll('</tr>', '\n');
    result = result.replaceAll('<br>', '\n');
    result = result.replaceAll('<br/>', '\n');
    result = result.replaceAll('<br />', '\n');

    // ลบ HTML tags ออก
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    result = result.replaceAll(exp, '');

    // แปลง HTML entities
    result = result.replaceAll('&nbsp;', ' ');
    result = result.replaceAll('&amp;', '&');
    result = result.replaceAll('&lt;', '<');
    result = result.replaceAll('&gt;', '>');
    result = result.replaceAll('&quot;', '"');
    result = result.replaceAll('&#39;', "'");

    // ลบช่องว่างซ้ำ
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return result.trim();
  }
}
