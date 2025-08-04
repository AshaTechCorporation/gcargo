import 'package:intl/intl.dart';

class NumberFormatter {
  // ฟอร์แมทตัวเลขให้มีคอมม่า (1,234.56)
  static String formatNumber(dynamic value, {int decimalPlaces = 2}) {
    if (value == null) return decimalPlaces == 0 ? '0' : '0.00';

    double number;

    // แปลงค่าต่างๆ เป็น double
    if (value is double) {
      number = value;
    } else if (value is int) {
      number = value.toDouble();
    } else if (value is String) {
      number = double.tryParse(value) ?? 0.0;
    } else {
      number = 0.0;
    }

    // สร้าง formatter ตาม decimal places ที่ต้องการ
    if (decimalPlaces == 0) {
      final formatter = NumberFormat('#,##0');
      return formatter.format(number.round());
    } else {
      final formatter = NumberFormat('#,##0.${'0' * decimalPlaces}');
      return formatter.format(number);
    }
  }

  // ฟอร์แมทเงิน (เพิ่มสัญลักษณ์สกุลเงิน)
  static String formatCurrency(dynamic value, {String symbol = '฿', int decimalPlaces = 2}) {
    final formattedNumber = formatNumber(value, decimalPlaces: decimalPlaces);
    return '$formattedNumber $symbol';
  }

  // ฟอร์แมทเงินหยวน
  static String formatCNY(dynamic value, {int decimalPlaces = 2}) {
    return formatCurrency(value, symbol: '¥', decimalPlaces: decimalPlaces);
  }

  // ฟอร์แมทเงินบาท
  static String formatTHB(dynamic value, {int decimalPlaces = 2}) {
    return formatCurrency(value, symbol: '฿', decimalPlaces: decimalPlaces);
  }

  // ฟอร์แมทน้ำหนัก
  static String formatWeight(dynamic value, {String unit = 'kg', int decimalPlaces = 1}) {
    final formattedNumber = formatNumber(value, decimalPlaces: decimalPlaces);
    return '$formattedNumber $unit';
  }

  // ฟอร์แมทปริมาตร
  static String formatVolume(dynamic value, {String unit = 'cbm', int decimalPlaces = 0}) {
    final formattedNumber = formatNumber(value, decimalPlaces: decimalPlaces);
    return '$formattedNumber $unit';
  }

  // ฟอร์แมทเปอร์เซ็นต์
  static String formatPercentage(dynamic value, {int decimalPlaces = 1}) {
    final formattedNumber = formatNumber(value, decimalPlaces: decimalPlaces);
    return '$formattedNumber%';
  }

  // แปลงค่าเป็น double (สำหรับการคำนวณ)
  static double toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      return 0.0;
    }
  }

  // แปลงค่าเป็น int (สำหรับการคำนวณ)
  static int toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    } else if (value is double) {
      return value.round();
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    } else {
      return 0;
    }
  }

  // ตรวจสอบว่าเป็นตัวเลขหรือไม่
  static bool isNumeric(dynamic value) {
    if (value == null) return false;

    if (value is num) return true;
    if (value is String) {
      return double.tryParse(value) != null;
    }

    return false;
  }

  // ฟอร์แมทตัวเลขแบบย่อ (1K, 1M, 1B)
  static String formatCompact(dynamic value) {
    final number = toDouble(value);

    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return formatNumber(number, decimalPlaces: 0);
    }
  }
}
