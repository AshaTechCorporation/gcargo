import 'dart:developer';

import 'package:gcargo/models/faq.dart';
import 'package:gcargo/models/manual.dart';
import 'package:gcargo/models/tegaboutus.dart';
import 'package:gcargo/models/wallettrans.dart';
import 'package:gcargo/services/accountService.dart';
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

      final data = await AccountService.getListWalletTrans();

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

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
  }

  // Method refresh ข้อมูล
  Future<void> refreshData() async {
    await getFaqs();
    await getManuals();
    await getNews();
  }
}
