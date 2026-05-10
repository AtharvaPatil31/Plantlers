part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final CartEntity        cart;
  final List<PlantEntity> suggestions;
  final bool              isPromoLoading;
  final String?           promoError;

  const CartLoaded({
    required this.cart,
    this.suggestions    = const [],
    this.isPromoLoading = false,
    this.promoError,
  });

  CartLoaded copyWith({
    CartEntity?        cart,
    List<PlantEntity>? suggestions,
    bool?              isPromoLoading,
    String?            promoError,
    bool               clearPromoError = false,
  }) =>
      CartLoaded(
        cart:           cart           ?? this.cart,
        suggestions:    suggestions    ?? this.suggestions,
        isPromoLoading: isPromoLoading ?? this.isPromoLoading,
        promoError:     clearPromoError ? null : (promoError ?? this.promoError),
      );

  @override
  List<Object?> get props => [cart, suggestions, isPromoLoading, promoError];
}

class CartError extends CartState {
  final String message;
  const CartError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Emitted after a successful order placement.
class CartOrderPlaced extends CartState {
  const CartOrderPlaced();
}
