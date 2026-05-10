import 'package:equatable/equatable.dart';

enum PlantCategory { petFriendly, lowLight, office, tropical, airPurifier }

enum WaterFrequency { daily, twiceWeekly, weekly, biweekly, monthly }
enum LightRequirement { fullSun, brightIndirect, lowLight, shade }
enum PetSafety { safe, toxic, mildlyToxic }
enum DifficultyLevel { beginner, intermediate, expert }

extension WaterFrequencyX on WaterFrequency {
  String get label {
    switch (this) {
      case WaterFrequency.daily:        return 'Daily';
      case WaterFrequency.twiceWeekly:  return 'Twice Weekly';
      case WaterFrequency.weekly:       return 'Weekly';
      case WaterFrequency.biweekly:     return 'Bi-weekly';
      case WaterFrequency.monthly:      return 'Monthly';
    }
  }
  String get icon => '💧';
}

extension LightRequirementX on LightRequirement {
  String get label {
    switch (this) {
      case LightRequirement.fullSun:         return 'Full Sun';
      case LightRequirement.brightIndirect:  return 'Bright Indirect';
      case LightRequirement.lowLight:        return 'Low Light';
      case LightRequirement.shade:           return 'Shade';
    }
  }
  String get icon => '☀️';
}

extension PetSafetyX on PetSafety {
  String get label {
    switch (this) {
      case PetSafety.safe:        return 'Pet Safe';
      case PetSafety.toxic:       return 'Not Pet Safe';
      case PetSafety.mildlyToxic: return 'Mildly Toxic';
    }
  }
  String get icon => '🐾';
}

extension DifficultyLevelX on DifficultyLevel {
  String get label {
    switch (this) {
      case DifficultyLevel.beginner:     return 'Beginner';
      case DifficultyLevel.intermediate: return 'Intermediate';
      case DifficultyLevel.expert:       return 'Expert';
    }
  }
}

class PlantEntity extends Equatable {
  final String id;
  final String name;
  final String subtitle;
  final String tag; // e.g. "TROPICAL LEAF", "INDOOR TREE"
  final double priceInr;
  final String imageUrl;
  final List<PlantCategory> categories;

  // ── Care guide fields (optional — filled from backend later) ─────────────
  final String?           description;
  final String?           careQuote;       // italic quote shown on detail page
  final WaterFrequency?   waterFrequency;
  final LightRequirement? lightRequirement;
  final PetSafety?        petSafety;
  final DifficultyLevel?  difficulty;
  final String?           humidity;        // e.g. "40–60%"
  final String?           temperature;     // e.g. "18–27°C"
  final String?           soilType;
  final String?           fertilizer;      // e.g. "Monthly in growing season"
  final String?           commonName;
  final String?           origin;
  final bool              isSustainable;
  final bool              isRareCollection;

  const PlantEntity({
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

  @override
  List<Object?> get props => [id, name, priceInr];
}
