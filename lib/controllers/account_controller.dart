import 'dart:developer';

import 'package:gcargo/models/faq.dart';
import 'package:gcargo/models/manual.dart';
import 'package:gcargo/models/tegaboutus.dart';
import 'package:gcargo/models/user.dart';
import 'package:gcargo/models/wallettrans.dart';
import 'package:gcargo/services/accountService.dart';
import 'package:gcargo/services/orderService.dart';
import 'package:get/get.dart';

class AccountController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  var faqs = <Faq>[].obs;
  var manuals = <Manual>[].obs;
  var news = <Manual>[].obs;
  var aboutUs = Rxn<Tegaboutus>();
  var walletTrans = Rxn<WalletTrans>().obs;
  var listWalletTrans = <WalletTrans>[].obs;
  var coupons = <Map<String, dynamic>>[].obs;
  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    log('🚀 AccountController onInit called');
  }

  Future<void> getFaqs() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await AccountService.getFaqs();

      if (data != null) {
        // ไม่ต้องทำอะไรเพิ่มเติมสำหรับ FAQ นี้
        faqs.value = data;
        log('FAQs: $faqs');
      } else {
        _setError('ไม่สามารถโหลดข้อมูล FAQ ได้');
      }
    } catch (e) {
      log('❌ Error in getFaqs: $e');
      _setError('ไม่สามารถโหลดข้อมูล FAQ ได้');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getManuals() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await AccountService.getManuals();

      if (data != null) {
        // ไม่ต้องทำอะไร
        manuals.value = data;
        log('Manuals: $manuals');
      } else {
        _setError('ไม่สามารถโหลดข้อมูล Manual ได้');
      }
    } catch (e) {
      log('❌ Error in getManuals: $e');
      _setError('ไม่สามารถโหลดข้อมูล Manual ได้');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getNews() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await AccountService.getNews();

      if (data != null) {
        // ไม่ต้องทำอะไร
        news.value = data;
        log('News: $news');
      } else {
        _setError('ไม่สามารถโหลดข้อมูล News ได้');
      }
    } catch (e) {
      log('❌ Error in getNews: $e');
      _setError('ไม่สามารถโหลดข้อมูล News ได้');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTegAboutUs() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await AccountService.getTegAboutUs();

      if (data != null) {
        // ไม่ต้องทำอะไร
        aboutUs.value = data;
        log('About Us: $aboutUs');
      } else {
        _setError('ไม่สามารถโหลดข้อมูล About Us ได้');
      }
    } catch (e) {
      log('❌ Error in getTegAboutUs: $e');
      _setError('ไม่สามารถโหลดข้อมูล About Us ได้');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getListWalletTrans() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      //final data = await AccountService.getListWalletTrans();
      final data = await OrderService.getWalletTransNew();

      if (data != null) {
        // ไม่ต้องทำอะไร
        listWalletTrans.value = data;
        log('List Wallet Trans: $listWalletTrans');
      } else {
        _setError('ไม่สามารถโหลดข้อมูล Wallet Trans ได้');
      }
    } catch (e) {
      log('❌ Error in getListWalletTrans: $e');
      _setError('ไม่สามารถโหลดข้อมูล Wallet Trans ได้');
    } finally {
      isLoading.value = false;
    }
  }

  // ฟังก์ชั่นสำหรับเรียก API คูปอง
  Future<void> getCoupons() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await AccountService.getCoupons();

      if (data != null) {
        coupons.value = data;
        log('Coupons: $coupons');
      } else {
        _setError('ไม่สามารถโหลดข้อมูลคูปองได้');
      }
    } catch (e) {
      log('❌ Error in getCoupons: $e');
      _setError('ไม่สามารถโหลดข้อมูลคูปองได้');
    } finally {
      isLoading.value = false;
    }
  }

  //เรียกดูข้อมูลยูสเซอร์ตามไอดี
  Future<void> getUserById() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final data = await AccountService.getUserById();

      if (data != null) {
        user.value = data;
        log('User: $user');
      } else {
        _setError('ไม่สามารถโหลดข้อมูล User ได้');
      }
    } catch (e) {
      log('❌ Error in getUserById: $e');
      _setError('ไม่สามารถโหลดข้อมูล User ได้');
    } finally {
      isLoading.value = false;
    }
  }

  // ฟังก์ชั่นสำหรับเพิ่มที่อยู่
  Future<void> addAddress(Map<String, dynamic> addressData) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await AccountService.addAddress(
        contact_name: addressData['contact_name'] ?? '',
        contact_phone: addressData['contact_phone'] ?? '',
        address: addressData['address'] ?? '',
        sub_district: addressData['sub_district'] ?? '',
        district: addressData['district'] ?? '',
        province: addressData['province'] ?? '',
        postal_code: addressData['postal_code'] ?? '',
        latitude: addressData['latitude'] ?? 0.0,
        longitude: addressData['longitude'] ?? 0.0,
      );

      if (result != null) {
        log('Address added successfully');
        // Refresh user data
        await getUserById();
      } else {
        _setError('ไม่สามารถเพิ่มที่อยู่ได้');
      }
    } catch (e) {
      log('❌ Error in addAddress: $e');
      _setError('ไม่สามารถเพิ่มที่อยู่ได้');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ฟังก์ชั่นสำหรับแก้ไขที่อยู่
  Future<void> editAddress(int id, Map<String, dynamic> addressData) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await AccountService.editAddress(
        id: id,
        contact_name: addressData['contact_name'] ?? '',
        contact_phone: addressData['contact_phone'] ?? '',
        address: addressData['address'] ?? '',
        sub_district: addressData['sub_district'] ?? '',
        district: addressData['district'] ?? '',
        province: addressData['province'] ?? '',
        postal_code: addressData['postal_code'] ?? '',
        latitude: addressData['latitude'] ?? 0.0,
        longitude: addressData['longitude'] ?? 0.0,
      );

      if (result != null) {
        log('Address updated successfully');
        // Refresh user data
        await getUserById();
      } else {
        _setError('ไม่สามารถแก้ไขที่อยู่ได้');
      }
    } catch (e) {
      log('❌ Error in editAddress: $e');
      _setError('ไม่สามารถแก้ไขที่อยู่ได้');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
  }

  // Method refresh ข้อมูล
  Future<void> refreshData() async {
    await getFaqs();
    await getManuals();
    await getNews();
    await getCoupons();
  }
}
