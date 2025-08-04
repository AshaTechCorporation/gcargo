import 'package:hive/hive.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 0)
class CartItem extends HiveObject {
  @HiveField(0)
  String numIid;

  @HiveField(1)
  String title;

  @HiveField(2)
  dynamic price;

  @HiveField(3)
  dynamic originalPrice;

  @HiveField(4)
  String nick;

  @HiveField(5)
  String detailUrl;

  @HiveField(6)
  String picUrl;

  @HiveField(7)
  String brand;

  @HiveField(8)
  int quantity;

  @HiveField(9)
  String selectedSize;

  @HiveField(10)
  String selectedColor;

  @HiveField(11)
  String name;

  @HiveField(12)
  DateTime addedAt;

  CartItem({
    required this.numIid,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.nick,
    required this.detailUrl,
    required this.picUrl,
    required this.brand,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    required this.name,
    required this.addedAt,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      numIid: map['num_iid'] ?? '',
      title: map['title'] ?? '',
      price: map['price'] ?? 0,
      originalPrice: map['orginal_price'] ?? 0,
      nick: map['nick'] ?? '',
      detailUrl: map['detail_url'] ?? '',
      picUrl: map['pic_url'] ?? '',
      brand: map['brand'] ?? '',
      quantity: map['quantity'] ?? 1,
      selectedSize: map['selectedSize'] ?? '',
      selectedColor: map['selectedColor'] ?? '',
      name: map['name'] ?? '',
      addedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'num_iid': numIid,
      'title': title,
      'price': price,
      'orginal_price': originalPrice,
      'nick': nick,
      'detail_url': detailUrl,
      'pic_url': picUrl,
      'brand': brand,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'name': name,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  double get priceAsDouble {
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  double get originalPriceAsDouble {
    if (originalPrice is double) return originalPrice;
    if (originalPrice is int) return originalPrice.toDouble();
    if (originalPrice is String) return double.tryParse(originalPrice.toString()) ?? 0.0;
    return 0.0;
  }
}
