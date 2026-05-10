import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

/// The full cart state — items + applied promo + computed totals.
class CartEntity extends Equatable {
  final List<CartItemEntity> items;
  final String?              appliedPromoCode;
  final double               promoDiscount;   // absolute ₹ discount
  final double               deliveryCharge;  // 0 = free

  const CartEntity({
    this.items           = const [],
    this.appliedPromoCode,
    this.promoDiscount   = 0,
    this.deliveryCharge  = 0,
  });

  // ── Computed ──────────────────────────────────────────────────────────────
  int    get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal  => items.fold(0, (sum, i) => sum + i.lineTotal);
  double get total     => subtotal - promoDiscount + deliveryCharge;
  double get savings   => promoDiscount;
  bool   get isEmpty   => items.isEmpty;
  bool   get isFreeDelivery => deliveryCharge == 0;

  CartEntity copyWith({
    List<CartItemEntity>? items,
    String?               appliedPromoCode,
    double?               promoDiscount,
    double?               deliveryCharge,
    bool                  clearPromo = false,
  }) =>
      CartEntity(
        items:            items            ?? this.items,
        appliedPromoCode: clearPromo ? null : (appliedPromoCode ?? this.appliedPromoCode),
        promoDiscount:    clearPromo ? 0   : (promoDiscount    ?? this.promoDiscount),
        deliveryCharge:   deliveryCharge   ?? this.deliveryCharge,
      );

  @override
  List<Object?> get props =>
      [items, appliedPromoCode, promoDiscount, deliveryCharge];
}
