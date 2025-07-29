import 'dart:developer';
import 'package:flutter/scheduler.dart';
import 'package:gcargo/models/imgbanner.dart';
import 'package:gcargo/models/orders/serviceTransporterById.dart';
import 'package:gcargo/models/rateShip.dart';
import 'package:gcargo/models/shipping.dart';
import 'package:gcargo/models/user.dart';
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
  final RxList<ImgBanner> imgBanners = <ImgBanner>[].obs;
  List<Shipping> ship_address = [];
  Shipping? select_ship_address;
  var extraServices = <ServiceTransporterById>[].obs;
  var rateShip = <RateShip>[].obs;

  @override
  void onInit() {
    super.onInit();
    log('🚀 HomeController onInit called');
    // เรียก API หลังจาก build เสร็จแล้วเพื่อหลีกเลี่ยง setState during build error
    SchedulerBinding.instance.addPostFrameCallback((_) {
      searchItemsFromAPI('Shirt');
      getExchangeRateFromAPI();
      getImgBannerFromAPI();
      getUserDataAndShippingAddresses();
      getExtraServicesFromAPI();
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

  Future<void> getImgBannerFromAPI() async {
    try {
      final imgData = await HomeService.getImgBanner();
      if (imgData != null && imgData is List<ImgBanner>) {
        imgBanners.value = imgData;
      } else {
        _setErrorRate('ไม่สามารถเชื่อมต่อ API ไม่พบข้อมูล');
      }
    } catch (e) {
      log('❌ Error in searchItems: $e');
      _setErrorRate('$e');
    }
  }

  // Method to fetch user data and populate shipping addresses
  Future<void> getUserDataAndShippingAddresses() async {
    try {
      final userData = await HomeService.getUserById();
      if (userData.ship_address != null && userData.ship_address!.isNotEmpty) {
        ship_address = userData.ship_address!;
        // Set first address as default selection
        select_ship_address = ship_address.first;
      } else {
        ship_address = [];
        select_ship_address = null;
      }
    } catch (e) {
      log('❌ Error fetching user data: $e');
      ship_address = [];
      select_ship_address = null;
    }
  }

  // Method to update selected shipping address
  void updateSelectedShippingAddress(Shipping address) {
    select_ship_address = address;
  }

  // Method to fetch extra services
  Future<void> getExtraServicesFromAPI() async {
    try {
      final services = await HomeService.getExtraService();
      extraServices.value = services;
    } catch (e) {
      log('❌ Error fetching extra services: $e');
      extraServices.clear();
    }
  }

  Future<void> getRateShipFromAPI() async {
    try {
      final rates = await HomeService.getRateShip();
      rateShip.value = rates;
    } catch (e) {
      log('❌ Error fetching rate ship: $e');
      rateShip.clear();
    }
  }
}
