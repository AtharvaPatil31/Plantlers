import 'package:equatable/equatable.dart';

enum PlantCategory { petFriendly, lowLight, office, tropical, airPurifier }

class PlantEntity extends Equatable {
  final String id;
  final String name;
  final String subtitle;
  final String tag; // e.g. "TROPICAL LEAF", "INDOOR TREE"
  final double priceInr;
  final String imageUrl;
  final List<PlantCategory> categories;

  const PlantEntity({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.tag,
    required this.priceInr,
    required this.imageUrl,
    required this.categories,
  });

  @override
  List<Object?> get props => [id, name, priceInr];
}
