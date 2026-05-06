import '../../domain/entities/plant_entity.dart';

class PlantModel {
  final String id;
  final String name;
  final String subtitle;
  final String tag;
  final double priceInr;
  final String imageUrl;
  final List<PlantCategory> categories;

  const PlantModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.tag,
    required this.priceInr,
    required this.imageUrl,
    required this.categories,
  });

  PlantEntity toEntity() => PlantEntity(
        id: id,
        name: name,
        subtitle: subtitle,
        tag: tag,
        priceInr: priceInr,
        imageUrl: imageUrl,
        categories: categories,
      );
}
