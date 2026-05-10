import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

// ── Get cart ──────────────────────────────────────────────────────────────────
class GetCartUseCase extends UseCase<CartEntity, NoParams> {
  final CartRepository _repo;
  GetCartUseCase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call(NoParams _) => _repo.getCart();
}

// ── Add item ──────────────────────────────────────────────────────────────────
class AddToCartParams extends Equatable {
  final PlantEntity plant;
  final String      potSize;
  final int         quantity;

  const AddToCartParams({
    required this.plant,
    this.potSize  = 'Medium Pot',
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [plant, potSize, quantity];
}

class AddToCartUseCase extends UseCase<CartEntity, AddToCartParams> {
  final CartRepository _repo;
  AddToCartUseCase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call(AddToCartParams p) =>
      _repo.addItem(plant: p.plant, potSize: p.potSize, quantity: p.quantity);
}

// ── Remove item ───────────────────────────────────────────────────────────────
class RemoveFromCartUseCase extends UseCase<CartEntity, String> {
  final CartRepository _repo;
  RemoveFromCartUseCase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call(String cartItemId) =>
      _repo.removeItem(cartItemId);
}

// ── Update quantity ───────────────────────────────────────────────────────────
class UpdateQtyParams extends Equatable {
  final String cartItemId;
  final int    quantity;
  const UpdateQtyParams({required this.cartItemId, required this.quantity});

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class UpdateCartQtyUseCase extends UseCase<CartEntity, UpdateQtyParams> {
  final CartRepository _repo;
  UpdateCartQtyUseCase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call(UpdateQtyParams p) =>
      _repo.updateQuantity(cartItemId: p.cartItemId, quantity: p.quantity);
}

// ── Apply promo ───────────────────────────────────────────────────────────────
class ApplyPromoUseCase extends UseCase<CartEntity, String> {
  final CartRepository _repo;
  ApplyPromoUseCase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call(String code) =>
      _repo.applyPromoCode(code);
}

// ── Remove promo ──────────────────────────────────────────────────────────────
class RemovePromoUseCase extends UseCase<CartEntity, NoParams> {
  final CartRepository _repo;
  RemovePromoUseCase(this._repo);

  @override
  Future<Either<Failure, CartEntity>> call(NoParams _) =>
      _repo.removePromoCode();
}

// ── Clear cart ────────────────────────────────────────────────────────────────
class ClearCartUseCase extends UseCase<void, NoParams> {
  final CartRepository _repo;
  ClearCartUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(NoParams _) => _repo.clearCart();
}

// ── Get suggestions ───────────────────────────────────────────────────────────
class GetCartSuggestionsParams extends Equatable {
  final List<String> excludeIds;
  const GetCartSuggestionsParams(this.excludeIds);

  @override
  List<Object?> get props => [excludeIds];
}

class GetCartSuggestionsUseCase
    extends UseCase<List<PlantEntity>, GetCartSuggestionsParams> {
  final CartRepository _repo;
  GetCartSuggestionsUseCase(this._repo);

  @override
  Future<Either<Failure, List<PlantEntity>>> call(
          GetCartSuggestionsParams p) =>
      _repo.getSuggestions(p.excludeIds);
}
