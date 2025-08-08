import 'package:flutter/material.dart';
import 'package:gcargo/utils/helpers.dart';

class ProductCardFromAPI extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String seller;
  final String price;
  final String detailUrl;
  final VoidCallback onTap;

  const ProductCardFromAPI({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.seller,
    required this.price,
    required this.detailUrl,
    required this.onTap,
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
                            fit: BoxFit.cover,
                            height: 130,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 130,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 130,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                          )
                          : Container(
                            height: 130,
                            width: double.infinity,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                ),
                //Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, color: Colors.grey)),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 32, maxHeight: 32),
                    child: Text(
                      seller,
                      style: TextStyle(fontSize: 12, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
