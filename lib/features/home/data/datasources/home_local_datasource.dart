import '../models/plant_model.dart';
import '../../domain/entities/plant_entity.dart';

abstract class HomeLocalDataSource {
  List<PlantModel> getPlants();
  List<String> getSearchSuggestions();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  List<PlantModel> getPlants() => _mockPlants;

  @override
  List<String> getSearchSuggestions() => _searchSuggestions;
}

// ── Search hint keywords ──────────────────────────────────────────────────────
const List<String> _searchSuggestions = [
  'Monstera Deliciosa',
  'Snake Plant',
  'Peace Lily',
  'Fiddle Leaf Fig',
  'Pothos Golden',
  'ZZ Plant',
  'Spider Plant',
  'Air Purifier Plants',
  'Pet Friendly Plants',
  'Low Light Plants',
  'Indoor Trees',
  'Rubber Plant',
];

// ── Hardcoded plant catalogue (swap with API/Firestore later) ─────────────────
const List<PlantModel> _mockPlants = [
  PlantModel(
    id: '1',
    name: 'Monstera Deliciosa',
    subtitle: 'Monstera Deliciosa',
    tag: 'TROPICAL LEAF',
    priceInr: 2000,
    imageUrl:
        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=400&q=80',
    categories: [PlantCategory.tropical, PlantCategory.office],
  ),
  PlantModel(
    id: '2',
    name: 'Fiddle Leaf Fig',
    subtitle: 'Ficus Lyrata',
    tag: 'INDOOR TREE',
    priceInr: 1800,
    imageUrl:
        'https://images.unsplash.com/photo-1599598425947-5202edd56bdb?w=400&q=80',
    categories: [PlantCategory.office, PlantCategory.lowLight],
  ),
  PlantModel(
    id: '3',
    name: 'Snake Plant Zeylanica',
    subtitle: 'Sansevieria Zeylanica',
    tag: 'LOW MAINTENANCE',
    priceInr: 850,
    imageUrl:
        'https://images.unsplash.com/photo-1572688484438-313a6e50c333?w=400&q=80',
    categories: [PlantCategory.lowLight, PlantCategory.petFriendly],
  ),
  PlantModel(
    id: '4',
    name: 'Spider Plant',
    subtitle: 'Chlorophytum Comosum',
    tag: 'AIR PURIFIER',
    priceInr: 650,
    imageUrl:
        'https://images.unsplash.com/photo-1585664811087-47f65abbad64?w=400&q=80',
    categories: [PlantCategory.airPurifier, PlantCategory.petFriendly],
  ),
  PlantModel(
    id: '5',
    name: 'Peace Lily',
    subtitle: 'Spathiphyllum Wallisii',
    tag: 'AIR PURIFIER',
    priceInr: 750,
    imageUrl:
        'https://images.unsplash.com/photo-1593691509543-c55fb32d8de5?w=400&q=80',
    categories: [PlantCategory.airPurifier, PlantCategory.lowLight],
  ),
  PlantModel(
    id: '6',
    name: 'Pothos Golden',
    subtitle: 'Epipremnum Aureum',
    tag: 'EASY CARE',
    priceInr: 450,
    imageUrl:
        'https://images.unsplash.com/photo-1611735341450-74d61e660ad2?w=400&q=80',
    categories: [PlantCategory.lowLight, PlantCategory.office, PlantCategory.petFriendly],
  ),
  PlantModel(
    id: '7',
    name: 'ZZ Plant',
    subtitle: 'Zamioculcas Zamiifolia',
    tag: 'LOW LIGHT HERO',
    priceInr: 1200,
    imageUrl:
        'https://images.unsplash.com/photo-1632207691143-643e2a9a9361?w=400&q=80',
    categories: [PlantCategory.lowLight, PlantCategory.office],
  ),
  PlantModel(
    id: '8',
    name: 'Rubber Plant',
    subtitle: 'Ficus Elastica',
    tag: 'STATEMENT PLANT',
    priceInr: 1500,
    imageUrl:
        'https://images.unsplash.com/photo-1598880940080-ff9a29891b85?w=400&q=80',
    categories: [PlantCategory.tropical, PlantCategory.office],
  ),
];
