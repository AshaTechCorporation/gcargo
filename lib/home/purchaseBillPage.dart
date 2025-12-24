import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gcargo/home/firstPage.dart';
import 'package:gcargo/models/optionsItem.dart';
import 'package:gcargo/models/orders/serviceTransporterById.dart';
import 'package:gcargo/models/partService.dart';
import 'package:gcargo/models/products.dart';
import 'package:get/get.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/home/couponSelectionPage.dart';
import 'package:gcargo/home/deliveryMethodPage.dart';
import 'package:gcargo/services/cart_service.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/utils/helpers.dart';

class PurchaseBillPage extends StatefulWidget {
  final List<Map<String, dynamic>>? productDataList;
  final String channel;

  const PurchaseBillPage({super.key, this.productDataList, required this.channel});

  @override
  State<PurchaseBillPage> createState() => _PurchaseBillPageState();
}

class _PurchaseBillPageState extends State<PurchaseBillPage> {
  bool taxChecked = false;
  int? selectedExtraServiceIndex;
  late HomeController homeController;
  late LanguageController languageController;
  List<Map<String, dynamic>> products = [];
  Map<String, dynamic> deliveryOptions = {'id': 1, 'name': 'ขนส่งทางรถ', 'nameEng': 'car'};
  bool isLoadingServices = true;
  bool isOrdering = false; // เพิ่ม loading state สำหรับการสั่งซื้อ
  TextEditingController noteController = TextEditingController();
  ServiceTransporterById? serviceSelected;
  Map<String, dynamic>? selectedCoupon; // เก็บคูปองที่เลือก

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'purchase_bill': 'ใบสั่งซื้อ',
        'order_summary': 'สรุปการสั่งซื้อ',
        'product_list': 'รายการสินค้า',
        'quantity': 'จำนวน',
        'price': 'ราคา',
        'total': 'รวม',
        'subtotal': 'ยอดรวม',
        'shipping_method': 'วิธีการจัดส่ง',
        'extra_services': 'บริการเสริม',
        'coupon': 'คูปอง',
        'select_coupon': 'เลือกคูปอง',
        'discount': 'ส่วนลด',
        'tax': 'ภาษี',
        'grand_total': 'ยอดรวมทั้งสิ้น',
        'notes': 'หมายเหตุ',
        'add_notes': 'เพิ่มหมายเหตุ',
        'place_order': 'สั่งซื้อ',
        'confirm_order': 'ยืนยันการสั่งซื้อ',
        'order_success': 'สร้างออเดอร์สำเร็จ!',
        'order_failed': 'เกิดข้อผิดพลาด',
        'loading': 'กำลังโหลด...',
        'processing_order': 'กำลังดำเนินการสั่งซื้อ...',
        'select_shipping': 'เลือกวิธีการจัดส่ง',
        'no_products': 'ไม่มีสินค้า',
        'error_occurred': 'เกิดข้อผิดพลาด',
        'try_again': 'ลองใหม่อีกครั้ง',
        'baht': 'บาท',
        'free': 'ฟรี',
        'shipping_fee': 'ค่าจัดส่ง',
        'service_fee': 'ค่าบริการ',
        'coupon_discount': 'ส่วนลดคูปอง',
        'vat': 'ภาษีมูลค่าเพิ่ม',
        'including_vat': 'รวมภาษี',
        'excluding_vat': 'ไม่รวมภาษี',
        'exchange_rate': 'อัตราแลกเปลี่ยน',
        'yuan_to_baht': 'หยวนต่อบาท',
        'no_services': 'ไม่มีบริการ',
        'land_transport': 'ขนส่งทางรถ',
        'sea_transport': 'ขนส่งทางเรือ',
        'air_transport': 'ขนส่งทางอากาศ',
        'select_payment_type': 'เลือกรูปแบบการชำระเงิน',
        'full_payment': 'ชำระเต็มจำนวน',
        'pay_full_amount': 'ชำระเงินครบทั้งหมดในครั้งเดียว',
        'split_70_30': 'แยกชำระ 30-70',
        'pay_70_percent_first': 'ชำระ 30% ก่อน ส่วนที่เหลือชำระทีหลัง',
        'split_50_50': 'แยกชำระ 50-50',
        'pay_50_percent_first': 'ชำระ 50% ก่อน ส่วนที่เหลือชำระทีหลัง',
        'cancel': 'ยกเลิก',
        'confirm': 'ตกลง',
      },
      'en': {
        'purchase_bill': 'Purchase Bill',
        'order_summary': 'Order Summary',
        'product_list': 'Product List',
        'quantity': 'Quantity',
        'price': 'Price',
        'total': 'Total',
        'subtotal': 'Subtotal',
        'shipping_method': 'Shipping Method',
        'extra_services': 'Extra Services',
        'coupon': 'Coupon',
        'select_coupon': 'Select Coupon',
        'discount': 'Discount',
        'tax': 'Tax',
        'grand_total': 'Grand Total',
        'notes': 'Notes',
        'add_notes': 'Add Notes',
        'place_order': 'Place Order',
        'confirm_order': 'Confirm Order',
        'order_success': 'Order Created Successfully!',
        'order_failed': 'An Error Occurred',
        'loading': 'Loading...',
        'processing_order': 'Processing Order...',
        'select_shipping': 'Select Shipping Method',
        'no_products': 'No Products',
        'error_occurred': 'An Error Occurred',
        'try_again': 'Try Again',
        'baht': 'Baht',
        'free': 'Free',
        'shipping_fee': 'Shipping Fee',
        'service_fee': 'Service Fee',
        'coupon_discount': 'Coupon Discount',
        'vat': 'VAT',
        'including_vat': 'Including VAT',
        'excluding_vat': 'Excluding VAT',
        'exchange_rate': 'Exchange Rate',
        'yuan_to_baht': 'Yuan to Baht',
        'no_services': 'No Services',
        'land_transport': 'Land Transport',
        'sea_transport': 'Sea Transport',
        'air_transport': 'Air Transport',
        'select_payment_type': 'Select Payment Type',
        'full_payment': 'Full Payment',
        'pay_full_amount': 'Pay the full amount at once',
        'split_70_30': 'Split Payment 70-30',
        'pay_70_percent_first': 'Pay 70% first, remaining later',
        'split_50_50': 'Split Payment 50-50',
        'pay_50_percent_first': 'Pay 50% first, remaining later',
        'cancel': 'Cancel',
        'confirm': 'Confirm',
      },
      'zh': {
        'purchase_bill': '购买单',
        'order_summary': '订单摘要',
        'product_list': '商品列表',
        'quantity': '数量',
        'price': '价格',
        'total': '总计',
        'subtotal': '小计',
        'shipping_method': '配送方式',
        'extra_services': '额外服务',
        'coupon': '优惠券',
        'select_coupon': '选择优惠券',
        'discount': '折扣',
        'tax': '税费',
        'grand_total': '总金额',
        'notes': '备注',
        'add_notes': '添加备注',
        'place_order': '下单',
        'confirm_order': '确认订单',
        'order_success': '订单创建成功！',
        'order_failed': '发生错误',
        'loading': '加载中...',
        'processing_order': '正在处理订单...',
        'select_shipping': '选择配送方式',
        'no_products': '无商品',
        'error_occurred': '发生错误',
        'try_again': '重试',
        'baht': '泰铢',
        'free': '免费',
        'shipping_fee': '运费',
        'service_fee': '服务费',
        'coupon_discount': '优惠券折扣',
        'vat': '增值税',
        'including_vat': '含税',
        'excluding_vat': '不含税',
        'exchange_rate': '汇率',
        'yuan_to_baht': '人民币对泰铢',
        'no_services': '无服务',
        'land_transport': '陆运',
        'sea_transport': '海运',
        'air_transport': '空运',
        'select_payment_type': '选择付款方式',
        'full_payment': '全额付款',
        'pay_full_amount': '一次性支付全部金额',
        'split_70_30': '分期付款 70-30',
        'pay_70_percent_first': '先付70%，余款稍后支付',
        'split_50_50': '分期付款 50-50',
        'pay_50_percent_first': '先付50%，余款稍后支付',
        'cancel': '取消',
        'confirm': '确认',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();

    // Get HomeController
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    // Initialize products list
    if (widget.productDataList != null && widget.productDataList!.isNotEmpty) {
      products = List.from(widget.productDataList!);
    } else {}

    // Fetch extra services
    _loadExtraServices();
  }

  // แสดงไดอะล็อกเลือกรูปแบบการชำระเงิน
  Future<String?> _showPaymentTypeDialog(BuildContext context) async {
    String? selectedPaymentType;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(getTranslation('select_payment_type')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    activeColor: kSubButtonColor,
                    title: Text(getTranslation('full_payment')),
                    subtitle: Text(getTranslation('pay_full_amount')),
                    value: '1',
                    groupValue: selectedPaymentType,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentType = value;
                      });
                    },
                  ),
                  const Divider(),
                  RadioListTile<String>(
                    activeColor: kSubButtonColor,
                    title: Text(getTranslation('split_50_50')),
                    subtitle: Text(getTranslation('pay_50_percent_first')),
                    value: '2',
                    groupValue: selectedPaymentType,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentType = value;
                      });
                    },
                  ),
                  const Divider(),
                  RadioListTile<String>(
                    activeColor: kSubButtonColor,
                    title: Text(getTranslation('split_70_30')),
                    subtitle: Text(getTranslation('pay_70_percent_first')),
                    value: '3',
                    groupValue: selectedPaymentType,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentType = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(getTranslation('cancel'))),
                ElevatedButton(
                  onPressed: selectedPaymentType != null ? () => Navigator.of(context).pop(selectedPaymentType) : null,
                  child: Text(getTranslation('confirm')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadExtraServices() async {
    setState(() {
      isLoadingServices = true;
    });

    await homeController.getExtraServicesFromAPI();

    setState(() {
      isLoadingServices = false;
    });
  }

  // Helper methods for price calculations
  double getExchangeRateValue(Map<String, dynamic> rateData) {
    if (rateData.isNotEmpty && rateData.containsKey('deposit_order_rate')) {
      final rate = rateData['deposit_order_rate'];
      if (rate is num) {
        return rate.toDouble();
      } else if (rate is String) {
        return double.tryParse(rate) ?? 4.0; // Default fallback rate
      }
    }
    return 4.0; // Default fallback rate
  }

  double calculateProductTotal(Map<String, dynamic> product) {
    final priceValue = product['price'];
    double price = 0.0;
    if (priceValue is num) {
      price = priceValue.toDouble();
    } else if (priceValue is String) {
      price = double.tryParse(priceValue) ?? 0.0;
    }
    final quantity = (product['quantity'] ?? 1) is int ? (product['quantity'] ?? 1) : int.tryParse(product['quantity']?.toString() ?? '1') ?? 1;
    return price * quantity;
  }

  double calculateTotalYuan() {
    return products.fold(0.0, (sum, product) => sum + calculateProductTotal(product));
  }

  // Helper method to parse double from dynamic value
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double calculateTotalBaht() {
    return calculateTotalYuan() * getExchangeRateValue(homeController.exchangeRate);
  }

  void updateProductQuantity(int index, int newQuantity) {
    setState(() {
      products[index]['quantity'] = newQuantity > 0 ? newQuantity : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exchangeRateData = homeController.exchangeRate;
    final exchangeRate = getExchangeRateValue(exchangeRateData);
    final totalYuan = calculateTotalYuan();
    final totalBaht = totalYuan * exchangeRate;
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back_ios_new, color: Colors.black)),
          title: Text(getTranslation('purchase_bill'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(getTranslation('shipping_method'), style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${deliveryOptions['name']}', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      IconButton(
                        onPressed: () async {
                          final selectedOption = await _showDeliveryMethodDialog();
                          if (selectedOption != null) {
                            setState(() {
                              deliveryOptions = selectedOption;
                            });
                          }
                        },
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                      ),
                    ],
                  ),

                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(getTranslation('product_list'), style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${products.fold(0, (sum, product) => sum + (product['quantity'] ?? 1) as int)} ชิ้น',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildProductSection(),
                  const SizedBox(height: 24),
                  const Divider(height: 24, color: Colors.orange),
                  Text(getTranslation('notes'), style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: getTranslation('add_notes'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 24),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CouponSelectionPage(selectedCoupon: selectedCoupon)),
                      );

                      if (result != null) {
                        setState(() {
                          selectedCoupon = result;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(getTranslation('coupon'), style: TextStyle(fontWeight: FontWeight.bold)),
                            if (selectedCoupon != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  selectedCoupon!['code'] ?? '',
                                  style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                                ),
                              ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black54),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // ✅ ด้านล่างสุด สรุปยอดสินค้า ตามภาพจริง
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 แถบอัตราแลกเปลี่ยน
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  alignment: Alignment.centerLeft,
                  color: Colors.white,
                  child: Text(
                    '${getTranslation('exchange_rate')}  1 ¥ = ${exchangeRate.toStringAsFixed(4)} ${getTranslation('yuan_to_baht')}',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ),

                // 🔻 ด้านล่างสุด ตามภาพเป๊ะ
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: GestureDetector(
                    onTap:
                        isOrdering
                            ? null
                            : () async {
                              // ป้องกันการกดซ้ำ
                              if (isOrdering) return;

                              setState(() {
                                isOrdering = true;
                              });

                              // Store context before async operations
                              final currentContext = context;

                              try {
                                // แสดงไดอะล็อกเลือกรูปแบบการชำระเงิน
                                String? paymentType;
                                if (widget.channel == 'link') {
                                  paymentType = '1';
                                } else {
                                  paymentType = '1';
                                  //paymentType = await _showPaymentTypeDialog(currentContext);
                                }
                                if (paymentType == null) {
                                  setState(() {
                                    isOrdering = false;
                                  });
                                  return;
                                }
                                print(paymentType);

                                List<PartService> addOnServices = [];
                                List<Products> orderProducts = [];

                                // Add selected extra service
                                if (serviceSelected != null) {
                                  final addOnService = PartService(serviceSelected!.id, serviceSelected!.standard_price);
                                  addOnServices.add(addOnService);
                                }

                                // Create products for order
                                for (var i = 0; i < products.length; i++) {
                                  final product = products[i];

                                  // Create options for this specific product
                                  List<OptionsItem> productOptionsItems = [];

                                  // Add selectedSize if available for this product
                                  if (product['selectedSize'] != null && product['selectedSize'].toString().isNotEmpty) {
                                    final sizeOption = OptionsItem(product['selectedSize'], '', 'size');
                                    productOptionsItems.add(sizeOption);
                                  }

                                  // Add selectedColor if available for this product
                                  if (product['selectedColor'] != null && product['selectedColor'].toString().isNotEmpty) {
                                    final colorOption = OptionsItem(product['selectedColor'], '', 'color');
                                    productOptionsItems.add(colorOption);
                                  }

                                  final orderProduct = Products(
                                    product['nick'] ?? '', // product_shop
                                    product['num_iid'] ?? '', // product_code
                                    product['title'] ?? '', // product_name
                                    product['detail_url'] ?? '', // product_url
                                    product['pic_url'] ?? '', // product_image
                                    product['name'] ?? '', // product_category
                                    'shopgs1', // product_store_type
                                    noteController.text, // product_note
                                    product['price']?.toString() ?? '0', // product_price
                                    product['quantity']?.toString() ?? '1', // product_qty
                                    addOnServices, // add_on_services
                                    productOptionsItems, // options specific to this product
                                  );
                                  orderProducts.add(orderProduct);
                                }
                                inspect(orderProducts);

                                // Calculate total price
                                final totalYuan = calculateTotalYuan();

                                // Get selected shipping address ID
                                final selectedAddressId = homeController.select_ship_address?.id;
                                print(selectedAddressId);

                                //Create order via API
                                final result = await HomeService.createOrder(
                                  date: DateTime.now().toIso8601String(),
                                  total_price: totalYuan,
                                  shipping_type: deliveryOptions['nameEng'] ?? 'car',
                                  payment_term: paymentType,
                                  note: noteController.text,
                                  importer_code: '',
                                  member_address_id: selectedAddressId == null ? '' : selectedAddressId.toString(),
                                  products: orderProducts,
                                  coupon: selectedCoupon,
                                  paymentType: paymentType,
                                );

                                log('✅ Order created successfully: $result');

                                // ลบสินค้าจาก API ก่อน ถ้ามี id ที่ไม่ใช่ 0
                                for (var product in products) {
                                  final productId = product['id'];
                                  if (productId != null && productId != 0) {
                                    try {
                                      await HomeService.deleteCartItem(productId is int ? productId : int.tryParse(productId.toString()) ?? 0);
                                    } catch (e) {
                                      log('❌ Error deleting cart item id $productId: $e');
                                    }
                                  }
                                }

                                // Remove ordered items from cart (Hive)
                                await _removeOrderedItemsFromCart();

                                // Show success message
                                if (mounted) {
                                  ScaffoldMessenger.of(
                                    currentContext,
                                  ).showSnackBar(SnackBar(content: Text(getTranslation('order_success')), backgroundColor: Colors.green));

                                  // Navigate back or to order confirmation page
                                  Navigator.pushAndRemoveUntil(
                                    currentContext,
                                    MaterialPageRoute(builder: (context) => FirstPage()),
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                log('❌ Error creating order: $e');

                                if (mounted) {
                                  ScaffoldMessenger.of(
                                    currentContext,
                                  ).showSnackBar(SnackBar(content: Text('${getTranslation('error_occurred')}: $e'), backgroundColor: Colors.red));
                                }
                              } finally {
                                // รีเซ็ต loading state
                                if (mounted) {
                                  setState(() {
                                    isOrdering = false;
                                  });
                                }
                              }
                            },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: isOrdering ? Colors.grey : kButtonColor, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          // 🔵 วงกลมมีเลข หรือ loading spinner
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isOrdering ? Colors.grey.shade600 : Color(0xFF2E73B9), // ฟ้าอ่อน
                              shape: BoxShape.circle,
                            ),
                            child:
                                isOrdering
                                    ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    )
                                    : Text(
                                      '${widget.productDataList!.length}',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isOrdering ? getTranslation('processing_order') : getTranslation('place_order'),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const Spacer(),
                          if (!isOrdering)
                            Text(
                              '¥${totalYuan.toStringAsFixed(2)} (฿ ${totalBaht.toStringAsFixed(2)})',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 🔹 แถบสีขาวบาง ๆ ด้านล่างสุด (ไม่กินพื้นที่)
                Container(height: 8, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ บริการเสริม (Row เดียวกับตัวเลือก)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getTranslation('extra_services'), style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Expanded(child: _buildExtraServicesSection()),
            ],
          ),
          const SizedBox(height: 12),

          // 🔻 สินค้าแต่ละรายการ
          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;

            return Column(
              children: [
                if (index > 0) const SizedBox(height: 16),
                _buildProductItem(
                  index: index,
                  image: product['pic_url'] ?? 'assets/images/unsplash1.png',
                  name: product['title'] ?? 'ไม่มีชื่อสินค้า',
                  price: _parseDouble(product['price']),
                  originalPrice: _parseDouble(product['orginal_price']),
                  qty: (product['quantity'] ?? 1) is int ? (product['quantity'] ?? 1) : int.tryParse(product['quantity']?.toString() ?? '1') ?? 1,
                  selectedSize: product['selectedSize'] ?? '',
                  selectedColor: product['selectedColor'] ?? '',
                  translatedTitle: product['translatedTitle'],
                  onAdd: () => updateProductQuantity(index, (product['quantity'] ?? 1) + 1),
                  onRemove: () => updateProductQuantity(index, (product['quantity'] ?? 1) - 1),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem({
    required int index,
    required String image,
    required String name,
    required double price,
    required int qty,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    double? originalPrice,
    String selectedSize = '',
    String selectedColor = '',
    String? translatedTitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildProductImage(image)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final exchangeRateData = homeController.exchangeRate;
                      final exchangeRate = getExchangeRateValue(exchangeRateData);
                      final totalPrice = price * qty;
                      final totalBaht = totalPrice * exchangeRate;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [Text('¥${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))],
                          ),
                          Text('฿${totalBaht.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      );
                    }),

                    // 🔸 ปุ่มเพิ่ม-ลด
                    Row(
                      children: [
                        _buildQtyButton(icon: Icons.remove, onPressed: onRemove),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Text('$qty', style: const TextStyle(fontSize: 16))),
                        _buildQtyButton(icon: Icons.add, onPressed: onAdd),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // แสดงชื่อสินค้าต้นฉบับ
                Text(name, style: const TextStyle(fontSize: 14)),
                // แสดงชื่อสินค้าที่แปลแล้ว (ถ้ามี)
                if (translatedTitle != null && translatedTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    translatedTitle,
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (selectedSize.isNotEmpty) _buildTag(selectedSize),
                    if (selectedColor.isNotEmpty) _buildTag(selectedColor, filled: true),
                    if (selectedSize.isEmpty && selectedColor.isEmpty) _buildTag('ไม่ได้เลือก', filled: false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(14), color: Colors.white),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }

  Widget _buildTag(String text, {bool filled = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? kButtondiableColor : Colors.transparent,
        border: Border.all(color: kButtonColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: kButtonColor), overflow: TextOverflow.ellipsis),
    );
  }

  // Helper method to build product image with URL formatting
  Widget _buildProductImage(String imageUrl) {
    // Use the formatImageUrl helper to handle // URLs
    final formattedUrl = formatImageUrl(imageUrl);

    // Check if it's a network image or local asset
    if (formattedUrl.startsWith('http')) {
      return Image.network(
        formattedUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(width: 60, height: 60, color: Colors.grey.shade200, child: Icon(Icons.image_not_supported, color: Colors.grey));
        },
      );
    } else {
      return Image.asset(imageUrl, width: 60, height: 60, fit: BoxFit.cover);
    }
  }

  // Method to build extra services section
  Widget _buildExtraServicesSection() {
    if (isLoadingServices) {
      return const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (homeController.extraServices.isEmpty) {
      return Text(getTranslation('no_services'), style: TextStyle(fontSize: 12, color: Colors.grey));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            homeController.extraServices.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;
              final isSelected = selectedExtraServiceIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedExtraServiceIndex = isSelected ? null : index;
                    serviceSelected = service;
                  });
                  inspect(serviceSelected);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.blue : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.name ?? '',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.blue : Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // Method to remove ordered items from cart
  Future<void> _removeOrderedItemsFromCart() async {
    try {
      // Get all cart items
      final cartItems = CartService.getCartItems();

      // No cart items, nothing to remove
      if (cartItems.isEmpty) return;

      // Indices of cart items to remove
      List<int> indicesToRemove = [];

      // Check each product in the order
      for (var orderProduct in products) {
        final orderNumId = orderProduct['num_iid']?.toString() ?? '';

        // Skip if no valid num_iid
        if (orderNumId.isEmpty) continue;

        // Find matching items in cart
        for (int i = 0; i < cartItems.length; i++) {
          final cartItem = cartItems[i];

          // Check if cart item matches order item
          if (cartItem.numIid == orderNumId) {
            // If sizes match (or both empty)
            final orderSize = orderProduct['selectedSize']?.toString() ?? '';
            final cartSize = cartItem.selectedSize;

            // If colors match (or both empty)
            final orderColor = orderProduct['selectedColor']?.toString() ?? '';
            final cartColor = cartItem.selectedColor;

            // If both size and color match (or both empty)
            if ((orderSize == cartSize) && (orderColor == cartColor)) {
              indicesToRemove.add(i);
              break; // Found a match, move to next order product
            }
          }
        }
      }

      // Remove matched items from cart
      if (indicesToRemove.isNotEmpty) {
        await CartService.removeMultipleItems(indicesToRemove);
        log('✅ Removed ${indicesToRemove.length} items from cart after successful order');
      }
    } catch (e) {
      // Log error but don't interrupt the flow
      log('❌ Error removing items from cart: $e');
    }
  }

  Future<Map<String, dynamic>?> _showDeliveryMethodDialog() async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        // เช็คตัวเลือกปัจจุบัน
        int? selectedDeliveryId;
        if (deliveryOptions['id'] == 1) {
          selectedDeliveryId = 1;
        } else if (deliveryOptions['id'] == 2) {
          selectedDeliveryId = 2;
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(getTranslation('shipping_method')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Radio<int>(
                      value: 1,
                      groupValue: selectedDeliveryId,
                      onChanged: (value) {
                        setState(() {
                          selectedDeliveryId = value;
                        });
                      },
                    ),
                    title: Row(children: [Icon(Icons.local_shipping, color: Colors.blue, size: 20), SizedBox(width: 8), Text('ทางรถ')]),
                    subtitle: Text('ขนส่งทางรถ'),
                    tileColor: selectedDeliveryId == 1 ? Colors.blue.shade50 : null,
                    onTap: () {
                      setState(() {
                        selectedDeliveryId = 1;
                      });
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Radio<int>(
                      value: 2,
                      groupValue: selectedDeliveryId,
                      onChanged: (value) {
                        setState(() {
                          selectedDeliveryId = value;
                        });
                      },
                    ),
                    title: Row(children: [Icon(Icons.directions_boat, color: Colors.blue, size: 20), SizedBox(width: 8), Text('ทางเรือ')]),
                    subtitle: Text('ขนส่งทางเรือ'),
                    tileColor: selectedDeliveryId == 2 ? Colors.blue.shade50 : null,
                    onTap: () {
                      setState(() {
                        selectedDeliveryId = 2;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(getTranslation('cancel'))),
                ElevatedButton(
                  onPressed:
                      selectedDeliveryId != null
                          ? () {
                            final selectedOption =
                                selectedDeliveryId == 1
                                    ? {'id': 1, 'name': 'ขนส่งทางรถ', 'type': 'car'}
                                    : {'id': 2, 'name': 'ขนส่งทางเรือ', 'type': 'ship'};
                            Navigator.of(context).pop(selectedOption);
                          }
                          : null,
                  child: Text('ตกลง'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
