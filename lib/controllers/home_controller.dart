import 'dart:developer';
import 'package:flutter/scheduler.dart';
import 'package:gcargo/models/imgbanner.dart';
import 'package:gcargo/models/orders/serviceTransporterById.dart';
import 'package:gcargo/models/payment.dart';
import 'package:gcargo/models/rateExchange.dart';
import 'package:gcargo/models/rateShip.dart';
import 'package:gcargo/models/shipping.dart';
import 'package:gcargo/models/transferFee.dart';
import 'package:gcargo/models/user.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gcargo/constants.dart';

class HomeController extends GetxController {
  final HomeService _homeService = HomeService();

  // Observable variables
  var isLoading = false.obs;
  final RxList<Map<String, dynamic>> searchItems = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var selectedItemType = ''.obs; // สำหรับเก็บ type ที่เลือก
  final RxMap<String, dynamic> exchangeRate = <String, dynamic>{}.obs;
  final RxList<ImgBanner> imgBanners = <ImgBanner>[].obs;
  List<Shipping> ship_address = [];
  Shipping? select_ship_address;
  var extraServices = <ServiceTransporterById>[].obs;
  var rateShip = <RateShip>[].obs;
  var rateExchange = Rxn<RateExchange>();
  var transferFee = Rxn<TransferFee>();
  var alipayPayment = <Payment>[].obs;
  var currentUser = Rxn<User>();
  var alipayPaymentById = Rxn<Payment>();
  var reward = <Map<String, dynamic>>[].obs;
  var rewardExchangeHistory = <Map<String, dynamic>>[].obs;
  var isLoadingRewardHistory = false.obs;

  // สำหรับเก็บไตเติ๊ลที่แปลแล้วของสินค้าในหน้าโฮม
  var translatedHomeTitles = <String, String>{}.obs;
  var isTranslatingHomeTitles = false.obs;

  @override
  void onInit() {
    super.onInit();
    log('🚀 HomeController onInit called');
    // ตั้งค่าเริ่มต้นให้เลือกตัวแรกของ itemType
    selectedItemType.value = itemType.first;
    // เรียก API หลังจาก build เสร็จแล้วเพื่อหลีกเลี่ยง setState during build error
    SchedulerBinding.instance.addPostFrameCallback((_) {
      getExchangeRateFromAPI();
      getImgBannerFromAPI();
      getUserDataAndShippingAddresses();
      getExtraServicesFromAPI();
      getServiceRateFromAPI();
      getServiceFeeFromAPI();
      searchItemsFromAPI('Shirt');
    });
  }

  Future<void> searchItemsFromAPI(String query) async {
    if (query.isEmpty) return;

    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await HomeService.getItemSearch(search: query, type: selectedItemType.value == 'shopgs1' ? 'taobao' : '1688', page: 1);

      // if (data != null && data is Map && data['item'] is Map && data['item']['items'] is Map && data['item']['items']['item'] is List && data['data']['item'] is List) {
      //   final List<Map<String, dynamic>> items = (data['item']['items']['item'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

      //   if (items.isNotEmpty) {
      //     searchItems.value = items;
      //     // แปลไตเติ๊ลหลังจากได้ข้อมูลสินค้า
      //     translateHomeTitles();
      //   } else {
      //     _setError('ไม่พบสินค้าที่ค้นหา');
      //   }
      // } else {
      //   _setError('ไม่สามารถเชื่อมต่อ API หรือไม่พบสินค้าที่ค้นหา');
      // }

      if (data['data']['item'] is List) {
        final List<Map<String, dynamic>> items = (data['data']['item'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

        if (items.isNotEmpty) {
          searchItems.value = items;
          // แปลไตเติ๊ลหลังจากได้ข้อมูลสินค้า
          translateHomeTitles();
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

  // ฟังก์ชันสำหรับแปลไตเติ๊ลของสินค้าในหน้าโฮม
  Future<void> translateHomeTitles() async {
    if (searchItems.isEmpty || isTranslatingHomeTitles.value) return;

    log('🔄 Starting home titles translation for ${searchItems.length} items');
    isTranslatingHomeTitles.value = true;

    try {
      // รวบรวมไตเติ๊ลทั้งหมดเพื่อส่งแปลครั้งเดียว
      final List<String> originalTitles = [];

      for (int i = 0; i < searchItems.length; i++) {
        final originalTitle = searchItems[i]['title']?.toString() ?? '';
        if (originalTitle.isNotEmpty) {
          originalTitles.add(originalTitle);
        }
      }

      if (originalTitles.isNotEmpty) {
        final Map<String, String> titleMap = {};

        // ครั้งที่ 1: ส่งแปลทั้งหมด
        await _translateTitlesRound(originalTitles, titleMap, 1);

        // เช็คว่าได้แปลครบหรือไม่
        final List<String> missingTitles = originalTitles.where((title) => !titleMap.containsKey(title)).toList();

        if (missingTitles.isNotEmpty) {
          log('🔄 Round 2: Translating ${missingTitles.length} missing titles');
          await _translateTitlesRound(missingTitles, titleMap, 2);
        }

        translatedHomeTitles.value = titleMap;
        log('🎉 Home titles translation completed. Total translated: ${titleMap.length}/${originalTitles.length}');
      }
    } catch (e) {
      log('❌ Error translating home titles: $e');
    } finally {
      isTranslatingHomeTitles.value = false;
    }
  }

  // ฟังก์ชันช่วยสำหรับแปลแต่ละรอบ
  Future<void> _translateTitlesRound(List<String> titlesToTranslate, Map<String, String> titleMap, int round) async {
    try {
      // รวมไตเติ๊ลด้วย separator
      final String combinedText = titlesToTranslate.join('|||');
      log('📝 Round $round - Combined text to translate: ${combinedText.length} characters');

      // ส่งแปลครั้งเดียว
      final String? translatedText = await HomeService.translate(text: combinedText, from: 'zh-CN', to: 'th');

      if (translatedText != null && translatedText.isNotEmpty) {
        // แยกผลลัพธ์ที่แปลแล้ว
        final List<String> translatedTitles = translatedText.split('|||');

        // จับคู่ไตเติ๊ลต้นฉบับกับที่แปลแล้ว
        for (int i = 0; i < titlesToTranslate.length && i < translatedTitles.length; i++) {
          final original = titlesToTranslate[i];
          final translated = translatedTitles[i].trim();
          if (translated.isNotEmpty) {
            titleMap[original] = translated;
            log('✅ Round $round - Translated: "$original" -> "$translated"');
          }
        }
      }
    } catch (e) {
      log('❌ Error in translation round $round: $e');
    }
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

  Future<void> getServiceRateFromAPI() async {
    try {
      final rateData = await HomeService.getServiceRate();
      if (rateData != null) {
        rateExchange.value = rateData;
      } else {
        _setErrorRate('ไม่สามารถเชื่อมต่อ API ไม่พบข้อมูลเรท');
      }
    } catch (e) {
      log('❌ Error in searchItems: $e');
      _setErrorRate('$e');
    }
  }

  Future<void> getServiceFeeFromAPI() async {
    try {
      final feeData = await HomeService.getServiceFee();
      if (feeData != null) {
        transferFee.value = feeData;
      } else {
        _setErrorRate('ไม่สามารถเชื่อมต่อ API ไม่พบข้อมูลเรท');
      }
    } catch (e) {
      log('❌ Error in searchItems: $e');
      _setErrorRate('$e');
    }
  }

  Future<void> getAlipayPaymentFromAPI() async {
    try {
      final paymentData = await HomeService.getAlipayPayment();
      if (paymentData != null) {
        alipayPayment.value = paymentData;
      } else {
        _setErrorRate('ไม่สามารถเชื่อมต่อ API ไม่พบข้อมูล');
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
      // เช็ค userID ก่อนเรียก API
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getInt('userID');

      if (userID != null) {
        final userData = await HomeService.getUserById();

        // เก็บข้อมูล user
        currentUser.value = userData;

        // จัดการ shipping addresses
        if (userData.ship_address != null && userData.ship_address!.isNotEmpty) {
          ship_address = userData.ship_address!;
          // Set first address as default selection
          select_ship_address = ship_address.first;
        } else {
          ship_address = [];
          select_ship_address = null;
        }

        // อัปเดต UI
        update();
      } else {
        log('⚠️ No userID found, skipping getUserById API call');
        currentUser.value = null;
        ship_address = [];
        select_ship_address = null;
      }
    } catch (e) {
      log('❌ Error fetching user data: $e');
      currentUser.value = null;
      ship_address = [];
      select_ship_address = null;
    }
  }

  Future<void> getAlipayPaymentById(int id) async {
    try {
      final paymentData = await HomeService.getAlipayPaymentById(id: id);
      if (paymentData != null) {
        alipayPaymentById.value = paymentData;
      } else {
        _setErrorRate('ไม่สามารถเชื่อมต่อ API ไม่พบข้อมูล');
      }
    } catch (e) {
      log('❌ Error in searchItems: $e');
      _setErrorRate('$e');
    }
  }

  // Method to fetch reward
  Future<void> getRewardFromAPI() async {
    try {
      final rewardData = await HomeService.getReward();
      if (rewardData != null) {
        reward.value = rewardData;
      } else {
        _setErrorRate('ไม่สามารถเชื่อมต่อ API ไม่พบข้อมูล');
      }
    } catch (e) {
      log('❌ Error in searchItems: $e');
      _setErrorRate('$e');
    }
  }

  // Method to fetch reward exchange history
  Future<void> getRewardExchangeFromAPI() async {
    try {
      isLoadingRewardHistory.value = true;
      final exchangeData = await HomeService.getRewardExchange();
      if (exchangeData != null) {
        rewardExchangeHistory.value = exchangeData;
      } else {
        _setErrorRate('ไม่สามารถเชื่อมต่อ API ไม่พบข้อมูลประวัติการแลก');
      }
    } catch (e) {
      log('❌ Error in getRewardExchange: $e');
      _setErrorRate('$e');
    } finally {
      isLoadingRewardHistory.value = false;
    }
  }

  // Method to update reward status (redeem reward)
  Future<bool> updateRewardStatus({required int reward_id}) async {
    try {
      final result = await HomeService.updateStatusReward(reward_id: reward_id);
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('❌ Error in updateRewardStatus: $e');
      return false;
    }
  }

  // Method to get user by ID
  Future<User?> getUserByIdFromAPI() async {
    try {
      final user = await HomeService.getUserById();
      return user;
    } catch (e) {
      log('❌ Error in getUserById: $e');
      return null;
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
