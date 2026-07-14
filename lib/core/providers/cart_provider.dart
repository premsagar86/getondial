import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends StateNotifier<Map<String, CartItem>> {
  CartNotifier() : super({});

  void addProduct(ProductModel product) {
    final existing = state[product.id];
    if (existing != null) {
      state = {
        ...state,
        product.id: existing.copyWith(quantity: existing.quantity + 1),
      };
    } else {
      state = {
        ...state,
        product.id: CartItem(product: product, quantity: 1),
      };
    }
  }

  void removeProduct(ProductModel product) {
    final existing = state[product.id];
    if (existing == null) return;

    if (existing.quantity > 1) {
      state = {
        ...state,
        product.id: existing.copyWith(quantity: existing.quantity - 1),
      };
    } else {
      final next = {...state};
      next.remove(product.id);
      state = next;
    }
  }

  void clearCart() {
    state = {};
  }

  int get totalItems => state.values.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, CartItem>>(
  (ref) => CartNotifier(),
);

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.values.fold(0, (sum, item) => sum + item.quantity);
});
