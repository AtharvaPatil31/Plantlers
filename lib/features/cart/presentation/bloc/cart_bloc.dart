import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/usecases/cart_usecases.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase            _getCart;
  final AddToCartUseCase          _addItem;
  final RemoveFromCartUseCase     _removeItem;
  final UpdateCartQtyUseCase      _updateQty;
  final ApplyPromoUseCase         _applyPromo;
  final RemovePromoUseCase        _removePromo;
  final ClearCartUseCase          _clearCart;
  final GetCartSuggestionsUseCase _getSuggestions;

  CartBloc({
    required GetCartUseCase            getCart,
    required AddToCartUseCase          addItem,
    required RemoveFromCartUseCase     removeItem,
    required UpdateCartQtyUseCase      updateQty,
    required ApplyPromoUseCase         applyPromo,
    required RemovePromoUseCase        removePromo,
    required ClearCartUseCase          clearCart,
    required GetCartSuggestionsUseCase getSuggestions,
  })  : _getCart        = getCart,
        _addItem        = addItem,
        _removeItem     = removeItem,
        _updateQty      = updateQty,
        _applyPromo     = applyPromo,
        _removePromo    = removePromo,
        _clearCart      = clearCart,
        _getSuggestions = getSuggestions,
        super(const CartInitial()) {
    on<CartLoadRequested>(_onLoad);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartQuantityUpdated>(_onQtyUpdated);
    on<CartPromoApplied>(_onPromoApplied);
    on<CartPromoRemoved>(_onPromoRemoved);
    on<CartCleared>(_onCleared);
    on<CartSuggestionsRequested>(_onSuggestionsRequested);
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> _onLoad(CartLoadRequested e, Emitter<CartState> emit) async {
    emit(const CartLoading());
    final result = await _getCart(const NoParams());
    result.fold(
      (f) => emit(CartError(message: f.message)),
      (cart) {
        emit(CartLoaded(cart: cart));
        // Load suggestions after cart is shown
        add(CartSuggestionsRequested(cart.items.map((i) => i.id).toList()));
      },
    );
  }

  // ── Add item ──────────────────────────────────────────────────────────────
  Future<void> _onItemAdded(CartItemAdded e, Emitter<CartState> emit) async {
    final current = state is CartLoaded ? state as CartLoaded : null;
    final result  = await _addItem(
        AddToCartParams(plant: e.plant, potSize: e.potSize, quantity: e.quantity));
    result.fold(
      (f) => emit(CartError(message: f.message)),
      (cart) => emit(
        current?.copyWith(cart: cart) ?? CartLoaded(cart: cart),
      ),
    );
  }

  // ── Remove item ───────────────────────────────────────────────────────────
  Future<void> _onItemRemoved(CartItemRemoved e, Emitter<CartState> emit) async {
    final current = state is CartLoaded ? state as CartLoaded : null;
    final result  = await _removeItem(e.cartItemId);
    result.fold(
      (f) => emit(CartError(message: f.message)),
      (cart) => emit(
        current?.copyWith(cart: cart) ?? CartLoaded(cart: cart),
      ),
    );
  }

  // ── Update quantity ───────────────────────────────────────────────────────
  Future<void> _onQtyUpdated(
      CartQuantityUpdated e, Emitter<CartState> emit) async {
    final current = state is CartLoaded ? state as CartLoaded : null;
    final result  = await _updateQty(
        UpdateQtyParams(cartItemId: e.cartItemId, quantity: e.quantity));
    result.fold(
      (f) => emit(CartError(message: f.message)),
      (cart) => emit(
        current?.copyWith(cart: cart) ?? CartLoaded(cart: cart),
      ),
    );
  }

  // ── Apply promo ───────────────────────────────────────────────────────────
  Future<void> _onPromoApplied(
      CartPromoApplied e, Emitter<CartState> emit) async {
    final current = state is CartLoaded ? state as CartLoaded : null;
    if (current == null) return;

    emit(current.copyWith(isPromoLoading: true, clearPromoError: true));
    final result = await _applyPromo(e.code);
    result.fold(
      (f) => emit(current.copyWith(
          isPromoLoading: false, promoError: f.message)),
      (cart) => emit(current.copyWith(cart: cart, isPromoLoading: false,
          clearPromoError: true)),
    );
  }

  // ── Remove promo ──────────────────────────────────────────────────────────
  Future<void> _onPromoRemoved(
      CartPromoRemoved e, Emitter<CartState> emit) async {
    final current = state is CartLoaded ? state as CartLoaded : null;
    if (current == null) return;
    final result = await _removePromo(const NoParams());
    result.fold(
      (f) => emit(CartError(message: f.message)),
      (cart) => emit(current.copyWith(cart: cart, clearPromoError: true)),
    );
  }

  // ── Clear cart ────────────────────────────────────────────────────────────
  Future<void> _onCleared(CartCleared e, Emitter<CartState> emit) async {
    await _clearCart(const NoParams());
    emit(const CartOrderPlaced());
  }

  // ── Suggestions ───────────────────────────────────────────────────────────
  Future<void> _onSuggestionsRequested(
      CartSuggestionsRequested e, Emitter<CartState> emit) async {
    final current = state is CartLoaded ? state as CartLoaded : null;
    if (current == null) return;
    final result = await _getSuggestions(GetCartSuggestionsParams(e.excludeIds));
    result.fold(
      (_) => null, // silently ignore suggestion errors
      (plants) => emit(current.copyWith(suggestions: plants)),
    );
  }
}
