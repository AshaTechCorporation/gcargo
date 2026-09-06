import 'package:flutter_test/flutter_test.dart';
import 'package:gcargo/controllers/product_detail_controller.dart';

void main() {
  late ProductDetailController controller;

  setUp(() {
    controller = ProductDetailController();
  });

  void setProps(dynamic props) {
    controller.productDetail.value = {
      'item': {
        'items': {
          'item': [
            {'props_list': props},
          ],
        },
      },
    };
  }

  test('keeps map props_list unchanged', () {
    final props = <String, dynamic>{
      '1627207:28341': '颜色分类:黑色',
    };
    setProps(props);

    expect(controller.propsList, same(props));
  });

  test('normalizes maps whose keys are not statically typed as strings', () {
    setProps(<dynamic, dynamic>{'1627207:28341': '颜色分类:黑色'});

    expect(controller.propsList, {
      '1627207:28341': '颜色分类:黑色',
    });
  });

  test('normalizes single-entry map items in list props_list', () {
    setProps([
      {'1627207:28341': '颜色分类:黑色'},
      {'20509:28314': '尺码:S'},
    ]);

    expect(controller.propsList, {
      '1627207:28341': '颜色分类:黑色',
      '20509:28314': '尺码:S',
    });
  });

  test('normalizes structured items in list props_list', () {
    setProps([
      {'key': '1627207:28341', 'name': '颜色分类', 'value': '黑色'},
      {'properties': '20509:28314', 'label': '尺码', 'option': 'S'},
    ]);

    expect(controller.propsList, {
      '1627207:28341': '颜色分类:黑色',
      '20509:28314': '尺码:S',
    });
  });

  test('normalizes string items and groups matching labels', () {
    setProps(['颜色分类:黑色', '颜色分类:白色', '尺码:S']);

    expect(controller.propsList, {
      '0:0': '颜色分类:黑色',
      '0:1': '颜色分类:白色',
      '1:2': '尺码:S',
    });
  });

  test('exposes a lone generic -1 category as a selectable option', () {
    setProps({
      '-1:6286573203702': '商品规格:【16V起子扳手 2.0Ah单电池】TR210T.1',
      '-1:6286573203703': '商品规格:【16V起子扳手 2.0Ah双电池】TR210T',
      '-1:6286573203704': '商品规格:【16V起子扳手 裸机无电池充电器】TR210T.9',
    });

    expect(controller.availableSizes, hasLength(3));
    expect(
      controller.sizeToKeyMapping[controller.availableSizes.first],
      '-1:6286573203702',
    );
  });

  test('does not expose a lone color category as sizes', () {
    setProps({
      '0:0': '颜色:白色',
      '0:1': '颜色:黑色',
    });

    expect(controller.availableColors, hasLength(2));
    expect(controller.availableSizes, isEmpty);
  });
}
