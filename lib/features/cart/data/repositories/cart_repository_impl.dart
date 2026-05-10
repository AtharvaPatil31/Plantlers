import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../home/data/datasources/home_local_datasource.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _cartDataSource;
  final HomeLocalDataSource _homeDataSource; // for suggestions

  CartRepositoryImpl({
    required CartLocalDataSource cartDataSource,
    required HomeLocalDataSource homeDataSource,
  })  : _cartDataSource = cartDataSource,
        _homeDataSource = homeDataSource;

  // ── Build CartEntity from current datasource state ────────────────────────
  CartEntity _buildCart() {
    final items    = _cartDataSource.getCartItems().map((m) => m.toEntity()).toList();
    final promo    = _cartDataSource.getAppliedPromoCode();
    final discount = _cartDataSource.getPromoDiscount();
    final subtotal = items.fold<double>(0, (s, i) => s + i.lineTotal);

    // Free delivery on orders above ₹999
    final delivery = subtotal >= 999 ? 0.0 : 99.0;

    return CartEntity(
      items:            items,
      appliedPromoCode: promo,
      promoDiscount:    discount,
      deliveryCharge:   delivery,
    );
  }

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      return Right(_buildCart());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addItem({
    required PlantEntity plant,
    required String potSize,
    int quantity = 1,
  }) async {
    try {
      final items = List<CartItemModel>.from(
          _cartDataSource.getCartItems().map((m) => m));

      final existingIdx = items.indexWhere((m) => m.id == plant.id);
      if (existingIdx >= 0) {
        // Increment quantity
        items[existingIdx] = items[existingIdx]
            .copyWith(quantity: items[existingIdx].quantity + quantity);
      } else {
        items.add(CartItemModel(
          id:       plant.id,
          plant:    plant,
          quantity: quantity,
          potSize:  potSize,
        ));
      }

      _cartDataSource.saveCartItems(items);
      return Right(_buildCart());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeItem(String cartItemId) async {
    try {
      final items = _cartDataSource
          .getCartItems()
          .where((m) => m.id != cartItemId)
          .toList();
      _cartDataSource.saveCartItems(items);
      return Right(_buildCart());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) return removeItem(cartItemId);

      final items = _cartDataSource.getCartItems().map((m) {
        if (m.id == cartItemId) return m.copyWith(quantity: quantity);
        return m;
      }).toList();

      _cartDataSource.saveCartItems(items);
      return Right(_buildCart());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> applyPromoCode(String code) async {
    try {
      final discount = _cartDataSource.applyPromoCode(code);
      if (discount == null) {
        return const Left(
            ServerFailure(message: 'Invalid promo code. Please try again.'));
      }
      _cartDataSource.savePromoCode(code.toUpperCase(), discount);
      return Right(_buildCart());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removePromoCode() async {
    try {
      _cartDataSource.clearPromoCode();
      return Right(_buildCart());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      _cartDataSource.clearCart();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlantEntity>>> getSuggestions(
      List<String> excludeIds) async {
    try {
      final all = _homeDataSource.getPlants();
      final suggestions = all
          .where((p) => !excludeIds.contains(p.id))
          .take(6)
          .map((m) => m.toEntity())
          .toList();
      return Right(suggestions);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
