import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  var currentLanguage = 'th'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage();
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language_code') ?? 'th';
    currentLanguage.value = savedLanguage;
    Get.updateLocale(Locale(savedLanguage));
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    currentLanguage.value = languageCode;
    Get.updateLocale(Locale(languageCode));

    // Force update all widgets that use GetBuilder<LanguageController>
    update();

    // Also trigger reactive updates
    currentLanguage.refresh();
  }

  String getNavLabel(String key) {
    return key.tr;
  }
}
