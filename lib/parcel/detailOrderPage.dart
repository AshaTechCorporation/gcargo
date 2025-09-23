import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/order_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/models/orders/productsTrack.dart';
import 'package:gcargo/parcel/paymentMethodPage.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/services/orderService.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DetailOrderPage extends StatefulWidget {
  final int orderId;

  const DetailOrderPage({super.key, required this.orderId});

  @override
  State<DetailOrderPage> createState() => _DetailOrderPageState();
}

class _DetailOrderPageState extends State<DetailOrderPage> {
  final OrderController orderController = Get.put(OrderController());
  final LanguageController languageController = Get.find<LanguageController>();
  double depositOrderRate = 4.0; // Default rate

  // สำหรับเก็บไตเติ๊ลที่แปลแล้ว
  Map<String, String> translatedProductTitles = {};
  bool isTranslatingTitles = false;

  // Worker สำหรับ dispose
  late Worker orderWorker;

  @override
  void initState() {
    super.initState();
    // Call getOrderById when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      orderController.getOrderById(widget.orderId);
      _loadExchangeRate();
    });

    // Listen to order changes and translate titles
    orderWorker = ever(orderController.order, (order) {
      if (order != null && order.order_lists != null && order.order_lists!.isNotEmpty) {
        _translateProductTitles();
      }
    });
  }

  @override
  void dispose() {
    orderWorker.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับแปลไตเติ๊ลสินค้า
  Future<void> _translateProductTitles() async {
    final order = orderController.order.value;
    if (order?.order_lists == null || order!.order_lists!.isEmpty || isTranslatingTitles) return;

    setState(() {
      isTranslatingTitles = true;
    });

    try {
      // รวบรวมไตเติ๊ลทั้งหมดเพื่อส่งแปลครั้งเดียว
      final List<String> originalTitles = [];

      for (final product in order.order_lists!) {
        final originalTitle = product.product_name ?? '';
        if (originalTitle.isNotEmpty && !translatedProductTitles.containsKey(originalTitle)) {
          originalTitles.add(originalTitle);
        }
      }

      if (originalTitles.isNotEmpty) {
        final Map<String, String> titleMap = Map.from(translatedProductTitles);

        // ครั้งที่ 1: ส่งแปลทั้งหมด
        await _translateTitlesRound(originalTitles, titleMap, 1);

        // เช็คว่าได้แปลครบหรือไม่
        final List<String> missingTitles = originalTitles.where((title) => !titleMap.containsKey(title)).toList();

        if (missingTitles.isNotEmpty) {
          print('🔄 Round 2: Translating ${missingTitles.length} missing product titles');
          await _translateTitlesRound(missingTitles, titleMap, 2);
        }

        if (mounted) {
          setState(() {
            translatedProductTitles = titleMap;
          });
        }

        print('🎉 Product titles translation completed. Total translated: ${titleMap.length}/${originalTitles.length}');
      }
    } catch (e) {
      print('❌ Error translating product titles: $e');
    } finally {
      if (mounted) {
        setState(() {
          isTranslatingTitles = false;
        });
      }
    }
  }

  // ฟังก์ชันช่วยสำหรับแปลแต่ละรอบ
  Future<void> _translateTitlesRound(List<String> titlesToTranslate, Map<String, String> titleMap, int round) async {
    try {
      // รวมไตเติ๊ลด้วย separator
      final String combinedText = titlesToTranslate.join('|||');
      print('📝 Round $round - Combined product titles to translate: ${combinedText.length} characters');

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
            print('✅ Round $round - Product translated: "$original" -> "$translated"');
          }
        }
      }
    } catch (e) {
      print('❌ Error in product translation round $round: $e');
    }
  }

  // Load exchange rate from API
  Future<void> _loadExchangeRate() async {
    try {
      final exchangeData = await HomeService.getExchageRate();
      if (exchangeData != null && exchangeData['deposit_order_rate'] != null) {
        setState(() {
          depositOrderRate = double.tryParse(exchangeData['deposit_order_rate'].toString()) ?? 4.0;
        });
      }
    } catch (e) {
      print('Error loading exchange rate: $e');
      // Keep default rate if API fails
    }
  }

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'order_details': 'รายละเอียดคำสั่งซื้อ',
        'contact': 'ติดต่อ',
        'shipping_type': 'รูปแบบการขนส่ง',
        'by_ship': 'ทางเรือ',
        'by_truck': 'ทางรถ',
        'customer_note': 'หมายเหตุของลูกค้า',
        'cs_note': 'CS หมายเหตุ',
        'order_date': 'วันที่สั่งซื้อ',
        'status': 'สถานะ',
        'total_price': 'ราคารวม',
        'all_products': 'สินค้าทั้งหมด',
        'no_products': 'ไม่มีรายการสินค้า',
        'price_summary': 'สรุปราคารวมสินค้า',
        'exchange_rate': 'เรทแลกเปลี่ยน',
        'product_total': 'รวมราคาสินค้า',
        'china_shipping': 'ค่าส่งในจีน',
        'service_fee': 'ค่าบริการ (3%)',
        'payment_term': 'เงื่อนไขการชำระ',
        'other_fees': 'ค่าบริการอื่น ๆ',
        'discount': 'ส่วนลด',
        'payment': 'การชำระเงิน',
        'calculated_total': 'ราคารวม (คำนวณ)',
        'deposit_fee': 'ค่ามัดจำ',
        'additional_info': 'ข้อมูลเพิ่มเติม',
        'order_created_date': 'วันที่สร้างออเดอร์',
        'member_code': 'รหัสสมาชิก',
        'total_amount': 'ราคารวม',
        'shipping_type_text': 'ประเภทการขนส่ง',
        'product_count_text': 'จำนวนสินค้า',
        'items_text': 'รายการ',
        'shipping_type_label': 'ประเภทการขนส่ง',
        'order_created': 'วันที่สร้างออเดอร์',
        'product_count': 'จำนวนสินค้า',
        'items': 'รายการ',
        'cancel': 'ยกเลิก',
        'buy_again': 'ซื้ออีกครั้ง',
        'cancel_success': 'ยกเลิกคำสั่งซื้อสำเร็จ',
        'awaiting_review': 'รอตรวจสอบ',
        'awaiting_payment': 'รอชำระเงิน',
        'in_progress': 'รอดำเนินการ',
        'preparing_shipment': 'เตรียมจัดส่ง',
        'shipped': 'สำเร็จ',
        'cancelled': 'ยกเลิก',
        'unknown_status': 'ไม่ทราบสถานะ',
        'document_notice': 'เอกสารจะจัดส่งให้ทางไลน์ภายใน 24 ชั่วโมง\nหลังจากชำระเงินสำเร็จ',
        'cancel_reason': 'ร้านค้าไม่มีสีตามที่สั่งซื้อจึงต้องยกเลิกรายการสินค้านี้',
        'unknown_product': 'ไม่ระบุชื่อสินค้า',
      },
      'en': {
        'order_details': 'Order Details',
        'contact': 'Contact',
        'shipping_type': 'Shipping Type',
        'by_ship': 'By Ship',
        'by_truck': 'By Truck',
        'customer_note': 'Customer Note',
        'cs_note': 'CS Note',
        'order_date': 'Order Date',
        'status': 'Status',
        'total_price': 'Total Price',
        'all_products': 'All Products',
        'no_products': 'No Products',
        'price_summary': 'Price Summary',
        'exchange_rate': 'Exchange Rate',
        'product_total': 'Product Total',
        'china_shipping': 'China Shipping',
        'service_fee': 'Service Fee (3%)',
        'payment_term': 'Payment Term',
        'other_fees': 'Other Fees',
        'discount': 'Discount',
        'payment': 'Payment',
        'calculated_total': 'Total (Calculated)',
        'deposit_fee': 'Deposit Fee',
        'additional_info': 'Additional Information',
        'order_created_date': 'Order Created Date',
        'member_code': 'Member Code',
        'total_amount': 'Total Amount',
        'shipping_type_text': 'Shipping Type',
        'product_count_text': 'Product Count',
        'items_text': 'Items',
        'shipping_type_label': 'Shipping Type',
        'order_created': 'Order Created',
        'product_count': 'Product Count',
        'items': 'Items',
        'cancel': 'Cancel',
        'buy_again': 'Buy Again',
        'cancel_success': 'Order cancelled successfully',
        'awaiting_review': 'Awaiting Review',
        'awaiting_payment': 'Awaiting Payment',
        'in_progress': 'In Progress',
        'preparing_shipment': 'Preparing Shipment',
        'shipped': 'Shipped',
        'cancelled': 'Cancelled',
        'unknown_status': 'Unknown Status',
        'document_notice': 'Documents will be sent via Line within 24 hours\nafter successful payment',
        'cancel_reason': 'Store does not have the color as ordered, so this item must be cancelled',
        'unknown_product': 'Unknown Product',
      },
      'zh': {
        'order_details': '订单详情',
        'contact': '联系',
        'shipping_type': '运输方式',
        'by_ship': '海运',
        'by_truck': '陆运',
        'customer_note': '客户备注',
        'cs_note': '客服备注',
        'order_date': '订单日期',
        'status': '状态',
        'total_price': '总价',
        'all_products': '所有商品',
        'no_products': '无商品',
        'price_summary': '价格汇总',
        'exchange_rate': '汇率',
        'product_total': '商品总价',
        'china_shipping': '中国运费',
        'service_fee': '服务费 (3%)',
        'payment_term': '付款条件',
        'other_fees': '其他费用',
        'discount': '折扣',
        'payment': '付款',
        'calculated_total': '总计 (计算)',
        'deposit_fee': '押金',
        'additional_info': '附加信息',
        'order_created_date': '订单创建日期',
        'member_code': '会员代码',
        'total_amount': '总金额',
        'shipping_type_text': '运输类型',
        'product_count_text': '商品数量',
        'items_text': '项',
        'shipping_type_label': '运输类型',
        'order_created': '订单创建',
        'product_count': '商品数量',
        'items': '项',
        'cancel': '取消',
        'buy_again': '再次购买',
        'cancel_success': '订单取消成功',
        'awaiting_review': '等待审核',
        'awaiting_payment': '等待付款',
        'in_progress': '进行中',
        'preparing_shipment': '准备发货',
        'shipped': '已发货',
        'cancelled': '已取消',
        'unknown_status': '未知状态',
        'document_notice': '文件将在付款成功后24小时内\n通过Line发送',
        'cancel_reason': '店铺没有订购的颜色，因此必须取消此商品',
        'unknown_product': '未知商品',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  // Helper methods to get data safely from API response
  String get orderCode => orderController.order.value?.code ?? 'N/A';
  String get orderStatus => _getStatusInThai(orderController.order.value?.status);
  String get orderDate => _formatDate(orderController.order.value?.date);
  String get transportType => orderController.order.value?.shipping_type ?? 'ไม่ระบุ';
  double get orderTotal => double.tryParse(orderController.order.value?.total_price ?? '0') ?? 0.0;
  String get memberCode => orderController.order.value?.member?.code ?? 'N/A';
  String get customerNote => orderController.order.value?.note ?? '-';
  List<ProductsTrack> get productList => orderController.order.value?.order_lists ?? [];

  // Status mapping from API to Thai
  String _getStatusInThai(String? apiStatus) {
    switch (apiStatus) {
      case 'awaiting_summary':
        return getTranslation('awaiting_review');
      case 'awaiting_payment':
        return getTranslation('awaiting_payment');
      case 'in_progress':
        return getTranslation('in_progress');
      case 'preparing_shipment':
        return getTranslation('preparing_shipment');
      case 'shipped':
        return getTranslation('shipped');
      case 'cancelled':
        return getTranslation('cancelled');
      default:
        return getTranslation('unknown_status');
    }
  }

  // Format date from API
  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Obx(() => Text('${getTranslation('order_details')} $orderCode', style: const TextStyle(color: Colors.black, fontSize: 24))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20)),
      ),
      body: Obx(() {
        // Show loading state
        if (orderController.isLoading.value) {
          return const SafeArea(child: Center(child: CircularProgressIndicator()));
        }

        // Show error state
        if (orderController.hasError.value) {
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(orderController.errorMessage.value, style: const TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => orderController.getOrderById(widget.orderId), child: const Text('ลองใหม่')),
                ],
              ),
            ),
          );
        }

        // Show empty state if no order data
        if (orderController.order.value == null) {
          return const SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ไม่พบข้อมูลออเดอร์', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    orderStatus == 'สำเร็จ'
                        ? Container(
                          width: double.infinity,
                          color: const Color(0xFFFFF7D8),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: const [
                              Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107)),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'เอกสารจะจัดส่งให้ทางไลน์ภายใน 24 ชั่วโมง\nหลังจากชำระเงินสำเร็จ',
                                  style: TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        )
                        : orderStatus == 'ยกเลิก'
                        ? Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: kTextRedWanningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Image.asset('assets/icons/info-circle.png', width: 20, height: 20),
                              const SizedBox(width: 8),
                              Text(getTranslation('cancel_reason'), style: TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                        : SizedBox(),
                    SizedBox(height: 12),
                    _buildInfoRow(getTranslation('contact'), '($memberCode)'),
                    _buildInfoRow(getTranslation('shipping_type'), transportType == 'Ship' ? getTranslation('by_ship') : getTranslation('by_truck')),
                    _buildInfoRow(getTranslation('customer_note'), customerNote),
                    _buildInfoRow(getTranslation('cs_note'), '-'),
                    _buildInfoRow(getTranslation('order_date'), orderDate),
                    _buildInfoRow(getTranslation('status'), orderStatus),
                    _buildInfoRow(getTranslation('total_price'), '¥${orderTotal.toStringAsFixed(2)}'),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 12),
                    Text(getTranslation('all_products'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kTextTitleHeadColor)),
                    SizedBox(height: 12),

                    // 🔹 การ์ดสินค้า
                    if (productList.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  productList.first.product_store_type ?? '1688',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextTitleHeadColor),
                                ),
                                Text(() {
                                  // เช็คข้อมูล add_on_service อย่างปลอดภัย
                                  final orderLists = orderController.order.value?.order_lists;
                                  if (orderLists == null || orderLists.isEmpty) return 'ไม่ QC | -';

                                  final addOnServices = orderLists.first.add_on_services;
                                  if (addOnServices == null || addOnServices.isEmpty) return 'ไม่ QC | -';

                                  final addOnService = addOnServices.first.add_on_service;
                                  final serviceName = addOnService?.name;

                                  return 'ไม่ QC | ${serviceName ?? '-'}';
                                }(), style: TextStyle(fontSize: 14, color: kTextgreyColor)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Builder(
                                  builder: (context) {
                                    final exchangeRate =
                                        double.tryParse(orderController.order.value?.exchange_rate ?? depositOrderRate.toString()) ??
                                        depositOrderRate;
                                    final chinaShippingFee = double.tryParse(orderController.order.value?.china_shipping_fee ?? '0') ?? 0.0;
                                    final chinaShippingBaht = chinaShippingFee * exchangeRate;

                                    return Text(
                                      'ค่าส่งต่อจีน ${chinaShippingFee.toStringAsFixed(2)}¥ / ${chinaShippingBaht.toStringAsFixed(2)}฿',
                                      style: TextStyle(fontSize: 14, color: kTextgreyColor),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // 🔻 รายการสินค้าจาก ProductsTrack
                            ...productList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final product = entry.value;
                              return Column(
                                children: [_buildProductItemFromTrack(product), if (index < productList.length - 1) const SizedBox(height: 12)],
                              );
                            }),
                          ],
                        ),
                      ),
                    ] else ...[
                      // แสดงข้อความเมื่อไม่มีสินค้า
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(getTranslation('no_products'), style: TextStyle(color: Colors.grey, fontSize: 16))),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // 🔹 สรุปราคา
                    _buildPriceSummary(),
                  ],
                ),
              ),

              // 🔻 ปุ่มล่าง - แสดงตามสถานะ
              _buildBottomButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(color: kHintTextColor, fontSize: 14))),
          Expanded(flex: 5, child: Text(value, style: const TextStyle(color: Colors.black, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildProductItemFromTrack(ProductsTrack product) {
    final productPrice = product.product_price ?? '0';
    final productQty = product.product_qty ?? 1;
    final productName = product.product_name ?? getTranslation('unknown_product');
    final translatedProductName = translatedProductTitles[product.product_name] ?? '';
    //final productImage = product.product_image;
    final productImage = formatImageUrl(product.product_image ?? '');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔺 รูปภาพสินค้า
        _buildProductImage(productImage),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¥$productPrice x$productQty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text('(${_calculateBahtPrice(productPrice)} ฿)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              // แสดงชื่อสินค้าต้นฉบับ
              Text(productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
              // แสดงชื่อสินค้าที่แปลแล้ว (ถ้ามี)
              if (translatedProductName.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  translatedProductName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 4),
              // แสดง options ถ้ามี
              if (product.options != null && product.options!.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children:
                      product.options!.map((option) {
                        return _buildTag(option.option_name ?? '', filled: true);
                      }).toList(),
                ),
            ],
          ),
        ),
        //const SizedBox(width: 8),
        //Text('¥$productPrice', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            );
          },
        ),
      );
    } else {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }

  String _calculateBahtPrice(String yuanPrice) {
    try {
      final yuan = double.parse(yuanPrice);
      final baht = yuan * depositOrderRate; // Assuming 1 Yuan = 4 Baht
      return baht.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  Widget _buildTag(String text, {bool filled = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: filled ? kCicleSelectedColor : Colors.transparent,
          border: Border.all(color: kCicleSelectedColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black)),
      ),
    );
  }

  Widget _buildPriceSummary() {
    final order = orderController.order.value;
    final totalProductPrice = _calculateTotalProductPrice();
    final totalBahtPrice = _calculateTotalBahtPrice();

    // Get data from API
    final exchangeRate = double.tryParse(order?.exchange_rate ?? depositOrderRate.toString()) ?? depositOrderRate;
    final chinaShippingFee = double.tryParse(order?.china_shipping_fee ?? '0') ?? 0.0;
    final depositFee = double.tryParse(order?.deposit_fee ?? '0') ?? 0.0;
    final totalPriceFromAPI = double.tryParse(order?.total_price ?? '0') ?? 0.0;
    final china_shipping_fee = order?.china_shipping_fee ?? '0';

    // Calculate additional fees
    final chinaShippingBaht = chinaShippingFee * exchangeRate;
    final depositBaht = depositFee * exchangeRate;
    final serviceFee = totalBahtPrice * 0.03; // 3% service fee
    final totalWithFees = totalBahtPrice + chinaShippingBaht + depositBaht + serviceFee;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceRow(getTranslation('price_summary'), '${getTranslation('exchange_rate')} ${exchangeRate.toStringAsFixed(2)}'),
          const Divider(),

          // Product details
          _buildPriceRow(getTranslation('product_total'), '¥${totalProductPrice.toStringAsFixed(2)} (${totalBahtPrice.toStringAsFixed(2)}฿)'),

          // China shipping fee
          if (chinaShippingFee > 0)
            _buildPriceRow(getTranslation('china_shipping'), '¥${chinaShippingFee.toStringAsFixed(2)} (${chinaShippingBaht.toStringAsFixed(2)}฿)')
          else
            _buildPriceRow(getTranslation('china_shipping'), '0.00฿'),

          // Deposit fee
          if (depositFee > 0)
            _buildPriceRow(getTranslation('deposit_fee'), ' (${depositFee.toStringAsFixed(2)}฿)')
          else
            _buildPriceRow(getTranslation('deposit_fee'), '0.00฿'),

          // Service fee
          // _buildPriceRow(getTranslation('service_fee'), '${serviceFee.toStringAsFixed(2)}฿'),

          // Payment term
          if (order?.payment_term != null && order!.payment_term!.isNotEmpty) _buildPriceRow(getTranslation('payment_term'), order.payment_term!),

          _buildPriceRow(getTranslation('other_fees'), '0.00฿'),
          _buildPriceRow(getTranslation('discount'), '0.00฿'),
          _buildPriceRow(getTranslation('payment'), '-'),

          const Divider(),

          // Total from API vs calculated
          if (totalPriceFromAPI > 0)
            _buildPriceRow(getTranslation('total_amount'), '${totalPriceFromAPI.toStringAsFixed(2)}¥)', isBold: true)
          else
            _buildPriceRow(getTranslation('calculated_total'), '${totalWithFees.toStringAsFixed(2)}฿', isBold: true),

          // Order info
          const SizedBox(height: 8),
          _buildInfoSection(),
        ],
      ),
    );
  }

  // Additional info section
  Widget _buildInfoSection() {
    final order = orderController.order.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(getTranslation('additional_info'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        if (order?.shipping_type != null)
          _buildPriceRow(
            getTranslation('shipping_type_text'),
            order!.shipping_type! == 'Ship' ? getTranslation('by_ship') : getTranslation('by_truck'),
          ),

        if (order?.created_at != null) _buildPriceRow(getTranslation('order_created_date'), _formatDate(order!.created_at.toString())),

        _buildPriceRow(getTranslation('product_count_text'), '${productList.length} ${getTranslation('items_text')}'),

        if (order?.member?.code != null) _buildPriceRow(getTranslation('member_code'), order!.member!.code!),
      ],
    );
  }

  double _calculateTotalProductPrice() {
    double total = 0.0;
    for (var product in productList) {
      try {
        final price = double.parse(product.product_price ?? '0');
        final qty = product.product_qty ?? 1;
        total += price * qty;
      } catch (e) {
        // Skip invalid prices
      }
    }
    return total;
  }

  double _calculateTotalBahtPrice() {
    return _calculateTotalProductPrice() * depositOrderRate; // Use API exchange rate
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
        ],
      ),
    );
  }

  // Build bottom buttons based on order status
  Widget _buildBottomButtons() {
    final status = orderController.order.value?.status;

    // Only show buttons for specific statuses
    print('🔍 Order status: $status');
    if (status == 'pending' || status == 'รอตรวจสอบ' || status == 'awaiting_payment' || status == 'รอชำระเงิน') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Cancel button (smaller size)
            Expanded(
              flex: 2, // Smaller flex ratio
              child: OutlinedButton(
                onPressed: () async {
                  print('🔘 กดปุ่มยกเลิก');
                  final cancelReason = await _showCancelReasonSheet(context);
                  print('📝 เหตุผล: $cancelReason');
                  if (cancelReason != null && cancelReason.isNotEmpty) {
                    print('✅ เรียก _cancelOrder');
                    await _cancelOrder(cancelReason);
                  } else {
                    print('❌ ไม่มีเหตุผล ไม่ยิง API');
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(getTranslation('cancel'), style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            // Second button depends on status (larger size)
            Expanded(
              flex: 3, // Larger flex ratio
              child: _buildSecondButton(status),
            ),
          ],
        ),
      );
    }

    // No buttons for other statuses
    return const SizedBox.shrink();
  }

  // Build second button based on status
  Widget _buildSecondButton(String? status) {
    if (status == 'shipped') {
      // For "รอตรวจสอบ" - show "ซื้ออีกครั้ง" button
      return ElevatedButton(
        onPressed: () {
          // แสดงข้อความว่าฟังก์ชันยังไม่พร้อมใช้งาน
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ฟังก์ชันนี้ยังไม่พร้อมใช้งาน'), backgroundColor: Colors.orange));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(getTranslation('buy_again'), style: TextStyle(fontSize: 16)),
      );
    } else if (status == 'awaiting_payment') {
      // For "รอชำระเงิน" - show price button with API total
      final order = orderController.order.value;
      final exchangeRate = double.tryParse(order?.exchange_rate ?? depositOrderRate.toString()) ?? depositOrderRate;
      final totalPriceFromAPI = double.tryParse(order?.total_price ?? '0') ?? 0.0;

      // Use API total if available, otherwise use calculated total
      final displayPrice = totalPriceFromAPI > 0 ? totalPriceFromAPI * exchangeRate : _calculateTotalBahtPrice();

      return ElevatedButton(
        onPressed: () {
          // TODO: Navigate to payment page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PaymentMethodPage(totalPrice: totalPriceFromAPI, ref_no: orderCode, orderType: 'order')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(getTranslation('total_amount'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(width: 5),
            if (totalPriceFromAPI > 0)
              Text('${totalPriceFromAPI.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ],
        ),
      );
    }

    // Default fallback (shouldn't reach here)
    return const SizedBox.shrink();
  }

  Future<void> _cancelOrder(String cancelReason) async {
    try {
      print('🚀 เริ่มยกเลิกออเดอร์ ID: ${widget.orderId}');
      print('📝 เหตุผล: $cancelReason');

      // แสดง loading
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

      // เรียก API ยกเลิกออเดอร์
      print('🌐 เรียก API updateStatusOrder...');
      final result = await OrderService.updateStatusOrder(status: 'cancelled', remark_cancel: cancelReason, orders: [widget.orderId]);
      print('✅ API Response: $result');

      // ปิด loading
      if (mounted) {
        Navigator.pop(context);

        // แสดงข้อความสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('cancel_success')), backgroundColor: Colors.green));

        // รีเฟรชข้อมูล orders
        await orderController.getOrders();
        print('🔄 รีเฟรชข้อมูลออเดอร์แล้ว');

        // กลับไปหน้า OrderStatusPage
        if (mounted) {
          print('📋 กำลังกลับไปหน้า OrderStatusPage พร้อมส่งค่า true');
          Navigator.pop(context, true); // ส่ง true เพื่อบอกว่ายกเลิกสำเร็จ
          print('📋 กลับไปหน้า OrderStatusPage แล้ว');
        }
      }
    } catch (e) {
      print('❌ Error: $e');
      // ปิด loading
      if (mounted) {
        Navigator.pop(context);

        // แสดงข้อความผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<String?> _showCancelReasonSheet(BuildContext context) async {
    final TextEditingController _reasonController = TextEditingController();

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔺 หัวข้อ + ปิด
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('หมายเหตุ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            print('❌ ปิด bottom sheet โดยไม่บันทึก');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 🔹 กล่องข้อความ
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                      child: TextField(
                        controller: _reasonController,
                        maxLines: 4,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'หมายเหตุ',
                          counterText: '', // ซ่อนตัวนับเดิม
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('${_reasonController.text.length}/200', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 ปุ่มบันทึก
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print('💾 บันทึกเหตุผล: "${_reasonController.text}"');
                          Navigator.pop(context, _reasonController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3C72),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('บันทึก', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
