import '../../../home/domain/entities/plant_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel {
  final String      id;
  final PlantEntity plant;
  final int         quantity;
  final String      potSize;

  const CartItemModel({
    required this.id,
    required this.plant,
    required this.quantity,
    required this.potSize,
  });

  CartItemEntity toEntity() => CartItemEntity(
        id:       id,
        plant:    plant,
        quantity: quantity,
        potSize:  potSize,
      );

  CartItemModel copyWith({int? quantity, String? potSize}) => CartItemModel(
        id:       id,
        plant:    plant,
        quantity: quantity ?? this.quantity,
        potSize:  potSize  ?? this.potSize,
      );
}
