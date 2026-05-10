import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../entities/cart_entity.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  /// Returns the current cart (from local storage).
  Future<Either<Failure, CartEntity>> getCart();

  /// Add a plant to the cart (or increment qty if already present).
  Future<Either<Failure, CartEntity>> addItem({
    required PlantEntity plant,
    required String potSize,
    int quantity,
  });

  /// Remove a specific item from the cart.
  Future<Either<Failure, CartEntity>> removeItem(String cartItemId);

  /// Update quantity of an existing item.
  Future<Either<Failure, CartEntity>> updateQuantity({
    required String cartItemId,
    required int quantity,
  });

  /// Apply a promo code — returns updated cart or failure.
  Future<Either<Failure, CartEntity>> applyPromoCode(String code);

  /// Remove the applied promo code.
  Future<Either<Failure, CartEntity>> removePromoCode();

  /// Clear the entire cart.
  Future<Either<Failure, void>> clearCart();

  /// Get suggested plants (for "You may also like").
  Future<Either<Failure, List<PlantEntity>>> getSuggestions(
      List<String> excludeIds);
}
