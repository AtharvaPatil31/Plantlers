import '../../domain/entities/plant_entity.dart';

class PlantModel {
  final String id;
  final String name;
  final String subtitle;
  final String tag;
  final double priceInr;
  final String imageUrl;
  final List<PlantCategory> categories;

  // ── Care guide fields ─────────────────────────────────────────────────────
  final String?           description;
  final String?           careQuote;
  final WaterFrequency?   waterFrequency;
  final LightRequirement? lightRequirement;
  final PetSafety?        petSafety;
  final DifficultyLevel?  difficulty;
  final String?           humidity;
  final String?           temperature;
  final String?           soilType;
  final String?           fertilizer;
  final String?           commonName;
  final String?           origin;
  final bool              isSustainable;
  final bool              isRareCollection;

  const PlantModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.tag,
    required this.priceInr,
    required this.imageUrl,
    required this.categories,
    this.description,
    this.careQuote,
    this.waterFrequency,
    this.lightRequirement,
    this.petSafety,
    this.difficulty,
    this.humidity,
    this.temperature,
    this.soilType,
    this.fertilizer,
    this.commonName,
    this.origin,
    this.isSustainable    = false,
    this.isRareCollection = false,
  });

  PlantEntity toEntity() => PlantEntity(
        id:               id,
        name:             name,
        subtitle:         subtitle,
        tag:              tag,
        priceInr:         priceInr,
        imageUrl:         imageUrl,
        categories:       categories,
        description:      description,
        careQuote:        careQuote,
        waterFrequency:   waterFrequency,
        lightRequirement: lightRequirement,
        petSafety:        petSafety,
        difficulty:       difficulty,
        humidity:         humidity,
        temperature:      temperature,
        soilType:         soilType,
        fertilizer:       fertilizer,
        commonName:       commonName,
        origin:           origin,
        isSustainable:    isSustainable,
        isRareCollection: isRareCollection,
      );
}
