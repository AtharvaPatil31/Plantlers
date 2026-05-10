part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {
  const CartLoadRequested();
}

class CartItemAdded extends CartEvent {
  final PlantEntity plant;
  final String      potSize;
  final int         quantity;

  const CartItemAdded({
    required this.plant,
    this.potSize  = 'Medium Pot',
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [plant, potSize, quantity];
}

class CartItemRemoved extends CartEvent {
  final String cartItemId;
  const CartItemRemoved(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class CartQuantityUpdated extends CartEvent {
  final String cartItemId;
  final int    quantity;

  const CartQuantityUpdated({
    required this.cartItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class CartPromoApplied extends CartEvent {
  final String code;
  const CartPromoApplied(this.code);

  @override
  List<Object?> get props => [code];
}

class CartPromoRemoved extends CartEvent {
  const CartPromoRemoved();
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartSuggestionsRequested extends CartEvent {
  final List<String> excludeIds;
  const CartSuggestionsRequested(this.excludeIds);

  @override
  List<Object?> get props => [excludeIds];
}
