// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 0;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      numIid: fields[0] as String,
      title: fields[1] as String,
      price: fields[2] as dynamic,
      originalPrice: fields[3] as dynamic,
      nick: fields[4] as String,
      detailUrl: fields[5] as String,
      picUrl: fields[6] as String,
      brand: fields[7] as String,
      quantity: fields[8] as int,
      selectedSize: fields[9] as String,
      selectedColor: fields[10] as String,
      name: fields[11] as String,
      addedAt: fields[12] as DateTime,
      translatedTitle: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.numIid)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.originalPrice)
      ..writeByte(4)
      ..write(obj.nick)
      ..writeByte(5)
      ..write(obj.detailUrl)
      ..writeByte(6)
      ..write(obj.picUrl)
      ..writeByte(7)
      ..write(obj.brand)
      ..writeByte(8)
      ..write(obj.quantity)
      ..writeByte(9)
      ..write(obj.selectedSize)
      ..writeByte(10)
      ..write(obj.selectedColor)
      ..writeByte(11)
      ..write(obj.name)
      ..writeByte(12)
      ..write(obj.addedAt)
      ..writeByte(13)
      ..write(obj.translatedTitle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
