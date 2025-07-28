import 'package:hive/hive.dart';
import 'package:gcargo/models/cart_item.dart';

class CartService {
  static const String _boxName = 'cart_box';
  static Box<CartItem>? _box;

  // Initialize Hive box
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CartItemAdapter());
    }
    _box = await Hive.openBox<CartItem>(_boxName);
  }

  // Get cart box
  static Box<CartItem> get _cartBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Cart box is not initialized. Call CartService.init() first.');
    }
    return _box!;
  }

  // Add item to cart
  static Future<void> addToCart(Map<String, dynamic> productData) async {
    final cartItem = CartItem.fromMap(productData);
    
    // Check if item already exists (same num_iid, size, color)
    final existingItemKey = _findExistingItem(
      cartItem.numIid,
      cartItem.selectedSize,
      cartItem.selectedColor,
    );

    if (existingItemKey != null) {
      // Update quantity of existing item
      final existingItem = _cartBox.get(existingItemKey);
      if (existingItem != null) {
        existingItem.quantity += cartItem.quantity;
        await existingItem.save();
      }
    } else {
      // Add new item
      await _cartBox.add(cartItem);
    }
  }

  // Get all cart items
  static List<CartItem> getCartItems() {
    return _cartBox.values.toList();
  }

  // Remove item from cart
  static Future<void> removeFromCart(int index) async {
    final items = getCartItems();
    if (index >= 0 && index < items.length) {
      await items[index].delete();
    }
  }

  // Remove multiple items from cart
  static Future<void> removeMultipleItems(List<int> indices) async {
    final items = getCartItems();
    // Sort indices in descending order to avoid index shifting issues
    indices.sort((a, b) => b.compareTo(a));
    
    for (int index in indices) {
      if (index >= 0 && index < items.length) {
        await items[index].delete();
      }
    }
  }

  // Update item quantity
  static Future<void> updateQuantity(int index, int newQuantity) async {
    final items = getCartItems();
    if (index >= 0 && index < items.length && newQuantity > 0) {
      items[index].quantity = newQuantity;
      await items[index].save();
    }
  }

  // Clear all cart items
  static Future<void> clearCart() async {
    await _cartBox.clear();
  }

  // Get cart items count
  static int getCartItemsCount() {
    return _cartBox.length;
  }

  // Get total cart value
  static double getTotalValue() {
    return getCartItems().fold(0.0, (total, item) {
      return total + (item.priceAsDouble * item.quantity);
    });
  }

  // Check if item exists in cart
  static bool isItemInCart(String numIid, String size, String color) {
    return _findExistingItem(numIid, size, color) != null;
  }

  // Find existing item key
  static dynamic _findExistingItem(String numIid, String size, String color) {
    for (var key in _cartBox.keys) {
      final item = _cartBox.get(key);
      if (item != null &&
          item.numIid == numIid &&
          item.selectedSize == size &&
          item.selectedColor == color) {
        return key;
      }
    }
    return null;
  }

  // Close the box (call this when app is closing)
  static Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
  }
}
