class ItemSearchResponse {
  final ItemData? item;
  final String? postUrl;

  ItemSearchResponse({
    this.item,
    this.postUrl,
  });

  factory ItemSearchResponse.fromJson(Map<String, dynamic> json) {
    return ItemSearchResponse(
      item: json['item'] != null ? ItemData.fromJson(json['item']) : null,
      postUrl: json['post_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item?.toJson(),
      'post_url': postUrl,
    };
  }
}

class ItemData {
  final ItemsData? items;

  ItemData({this.items});

  factory ItemData.fromJson(Map<String, dynamic> json) {
    return ItemData(
      items: json['items'] != null ? ItemsData.fromJson(json['items']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items?.toJson(),
    };
  }
}

class ItemsData {
  final String? page;
  final String? realTotalResults;
  final String? totalResults;
  final int? pageSize;
  final String? pagecount;
  final String? dataFrom;
  final List<Item>? item;
  final int? itemWeightUpdate;

  ItemsData({
    this.page,
    this.realTotalResults,
    this.totalResults,
    this.pageSize,
    this.pagecount,
    this.dataFrom,
    this.item,
    this.itemWeightUpdate,
  });

  factory ItemsData.fromJson(Map<String, dynamic> json) {
    return ItemsData(
      page: json['page'],
      realTotalResults: json['real_total_results'],
      totalResults: json['total_results'],
      pageSize: json['page_size'],
      pagecount: json['pagecount'],
      dataFrom: json['data_from'],
      item: json['item'] != null
          ? (json['item'] as List).map((i) => Item.fromJson(i)).toList()
          : null,
      itemWeightUpdate: json['item_weight_update'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'real_total_results': realTotalResults,
      'total_results': totalResults,
      'page_size': pageSize,
      'pagecount': pagecount,
      'data_from': dataFrom,
      'item': item?.map((i) => i.toJson()).toList(),
      'item_weight_update': itemWeightUpdate,
    };
  }
}

class Item {
  final String? title;
  final String? picUrl;
  final dynamic promotionPrice;
  final dynamic orginalPrice;
  final dynamic price;
  final int? sales;
  final String? numIid;
  final String? sellerNick;
  final String? detailUrl;

  Item({
    this.title,
    this.picUrl,
    this.promotionPrice,
    this.orginalPrice,
    this.price,
    this.sales,
    this.numIid,
    this.sellerNick,
    this.detailUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      title: json['title'],
      picUrl: json['pic_url'],
      promotionPrice: json['promotion_price'],
      orginalPrice: json['orginal_price'],
      price: json['price'],
      sales: json['sales'],
      numIid: json['num_iid'],
      sellerNick: json['seller_nick'],
      detailUrl: json['detail_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'pic_url': picUrl,
      'promotion_price': promotionPrice,
      'orginal_price': orginalPrice,
      'price': price,
      'sales': sales,
      'num_iid': numIid,
      'seller_nick': sellerNick,
      'detail_url': detailUrl,
    };
  }
}
