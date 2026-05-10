import 'dart:convert';
import '../../../../core/errors/exceptions.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../models/cart_item_model.dart';

/// Valid promo codes — in production these come from your backend.
const _promoCodes = <String, double>{
  'PLANT10': 450.0,
  'PLANTLERS': 500.0,
  'GREEN20': 300.0,
};

abstract class CartLocalDataSource {
  List<CartItemModel> getCartItems();
  void saveCartItems(List<CartItemModel> items);
  void clearCart();
  double? applyPromoCode(String code);   // returns discount or null if invalid
  String? getAppliedPromoCode();
  double  getPromoDiscount();
  void    savePromoCode(String code, double discount);
  void    clearPromoCode();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  // In-memory store — swap with SharedPreferences/Hive for persistence
  final List<CartItemModel> _items = [];
  String? _promoCode;
  double  _promoDiscount = 0;

  @override
  List<CartItemModel> getCartItems() => List.unmodifiable(_items);

  @override
  void saveCartItems(List<CartItemModel> items) {
    _items
      ..clear()
      ..addAll(items);
  }

  @override
  void clearCart() {
    _items.clear();
    _promoCode     = null;
    _promoDiscount = 0;
  }

  @override
  double? applyPromoCode(String code) {
    final discount = _promoCodes[code.toUpperCase()];
    return discount;
  }

  @override
  String? getAppliedPromoCode() => _promoCode;

  @override
  double getPromoDiscount() => _promoDiscount;

  @override
  void savePromoCode(String code, double discount) {
    _promoCode     = code;
    _promoDiscount = discount;
  }

  @override
  void clearPromoCode() {
    _promoCode     = null;
    _promoDiscount = 0;
  }
}
