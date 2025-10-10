import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/utils/helpers.dart';

class ProductCardFromAPI extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String seller;
  final String price;
  final String detailUrl;
  final VoidCallback onTap;
  final String? translatedTitle;

  const ProductCardFromAPI({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.seller,
    required this.price,
    required this.detailUrl,
    required this.onTap,
    this.translatedTitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  child:
                      imageUrl.isNotEmpty
                          ? Image.network(
                            formatImageUrl(imageUrl),
                            fit: BoxFit.fill,
                            height: isPhone(context) ? 130 : 200,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: isPhone(context) ? 130 : 200,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: isPhone(context) ? 130 : 200,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                          )
                          : Container(
                            height: isPhone(context) ? 130 : 200,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                ),
                //Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, color: Colors.grey)),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // แสดงชื่อสินค้าต้นฉบับ
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: isPhone(context) ? 14 : 20, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // แสดงชื่อสินค้าที่แปลแล้ว (ถ้ามี)
                    if (translatedTitle != null && translatedTitle!.isNotEmpty) ...[
                      SizedBox(height: 1),
                      Text(
                        translatedTitle!,
                        style: TextStyle(fontSize: isPhone(context) ? 12 : 20, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 1),
                    // Expanded(
                    //   child: Text(seller, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    // ),
                    Text(price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isPhone(context) ? 14 : 20, color: Colors.black)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
