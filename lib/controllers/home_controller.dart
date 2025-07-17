import 'dart:developer';
import 'package:flutter/scheduler.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final HomeService _homeService = HomeService();

  // Observable variables
  var isLoading = false.obs;
  final RxList<Map<String, dynamic>> searchItems = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  final RxMap<String, dynamic> exchangeRate = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    log('🚀 HomeController onInit called');
    // เรียก API หลังจาก build เสร็จแล้วเพื่อหลีกเลี่ยง setState during build error
    SchedulerBinding.instance.addPostFrameCallback((_) {
      searchItemsFromAPI('Shirt');
      getExchangeRateFromAPI();
    });
  }

  Future<void> searchItemsFromAPI(String query) async {
    if (query.isEmpty) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await HomeService.getItemSearch(search: query, type: 'taobao', page: 1);

      if (data != null && data is Map && data['item'] is Map && data['item']['items'] is Map && data['item']['items']['item'] is List) {
        final List<Map<String, dynamic>> items =
            (data['item']['items']['item'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

        if (items.isNotEmpty) {
          searchItems.value = items;
        } else {
          _setError('ไม่พบสินค้าที่ค้นหา');
        }
      } else {
        _setError('ไม่สามารถเชื่อมต่อ API หรือไม่พบสินค้าที่ค้นหา');
      }
    } catch (e) {
      log('❌ Error in searchItems: $e');
      _setError('ไม่สามารถเชื่อมต่อ API หรือไม่พบสินค้าที่ค้นหา');
    } finally {
      isLoading.value = false;
    }
  }

  bool _isValidResponseStructure(dynamic responseBody) {
    try {
      // ตรวจสอบว่ามี structure ตามที่กำหนดหรือไม่
      if (responseBody is! Map<String, dynamic>) return false;

      final item = responseBody['item'];
      if (item is! Map<String, dynamic>) return false;

      final items = item['items'];
      if (items is! Map<String, dynamic>) return false;

      final itemList = items['item'];
      if (itemList is! List) return false;

      // ตรวจสอบว่า item แรกมี field ที่จำเป็นหรือไม่
      if (itemList.isNotEmpty) {
        final firstItem = itemList[0];
        if (firstItem is! Map<String, dynamic>) return false;

        // ตรวจสอบ required fields
        final requiredFields = ['title', 'pic_url', 'price', 'num_iid'];
        for (String field in requiredFields) {
          if (!firstItem.containsKey(field)) return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    searchItems.clear();
  }

  // Method สำหรับ refresh ข้อมูล
  Future<void> refreshData() async {
    await searchItemsFromAPI('Shirt');
  }

  // Method สำหรับค้นหาใหม่
  Future<void> newSearch(String query) async {
    await searchItemsFromAPI(query);
  }

  void _setErrorRate(String message) {
    hasError.value = true;
    errorMessage.value = message;
    exchangeRate.clear();
  }

  Future<void> getExchangeRateFromAPI() async {
    try {
      final rateData = await HomeService.getExchageRate();
      if (rateData != null && rateData is Map<String, dynamic>) {
        exchangeRate.value = rateData;
      } else {
        _setErrorRate('ไม่สามารถเชื่อมต่อ API ไม่พบข้อมูลเรท');
      }
    } catch (e) {
      log('❌ Error in searchItems: $e');
      _setErrorRate('$e');
    }
  }
}
