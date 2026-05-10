import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/plant_entity.dart';

/// A single line-item in the cart.
class CartItemEntity extends Equatable {
  final String      id;        // cart-item id (plant.id used as key)
  final PlantEntity plant;
  final int         quantity;
  final String      potSize;   // e.g. "Small Pot", "Medium Pot", "Large Pot"

  const CartItemEntity({
    required this.id,
    required this.plant,
    required this.quantity,
    required this.potSize,
  });

  double get lineTotal => plant.priceInr * quantity;

  CartItemEntity copyWith({int? quantity, String? potSize}) => CartItemEntity(
        id:       id,
        plant:    plant,
        quantity: quantity ?? this.quantity,
        potSize:  potSize  ?? this.potSize,
      );

  @override
  List<Object?> get props => [id, plant, quantity, potSize];
}
