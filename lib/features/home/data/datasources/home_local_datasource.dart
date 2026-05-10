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

// ── Hardcoded plant catalogue (swap with API/Supabase later) ──────────────────
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
    description:
        'A stunning tropical plant known for its iconic Swiss-cheese-like leaves. '
        'Perfect for adding a bold statement to any room, its sculptural foliage '
        'adds a touch of the exotic to your living space while naturally purifying the air.',
    careQuote:
        '"This plant offsets 0.3kg CO₂/year. Freshly nurtured, packed with care."',
    waterFrequency:   WaterFrequency.weekly,
    lightRequirement: LightRequirement.brightIndirect,
    petSafety:        PetSafety.toxic,
    difficulty:       DifficultyLevel.beginner,
    humidity:         '60–80%',
    temperature:      '18–27°C',
    soilType:         'Well-draining potting mix',
    fertilizer:       'Monthly in growing season',
    commonName:       'Swiss Cheese Plant',
    origin:           'Central America',
    isSustainable:    true,
    isRareCollection: true,
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
    description:
        'The Fiddle Leaf Fig is a dramatic indoor tree with large, violin-shaped '
        'leaves. A favourite of interior designers, it thrives in bright, indirect '
        'light and makes an instant focal point in any space.',
    careQuote: '"A designer\'s favourite — bold, architectural, and alive."',
    waterFrequency:   WaterFrequency.weekly,
    lightRequirement: LightRequirement.brightIndirect,
    petSafety:        PetSafety.toxic,
    difficulty:       DifficultyLevel.intermediate,
    humidity:         '30–65%',
    temperature:      '16–24°C',
    soilType:         'Rich, well-draining soil',
    fertilizer:       'Every 2 weeks in spring/summer',
    commonName:       'Fiddle Leaf Fig',
    origin:           'West Africa',
    isSustainable:    false,
    isRareCollection: false,
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
    description:
        'One of the most resilient houseplants you can own. The Snake Plant '
        'tolerates neglect, low light, and irregular watering — making it perfect '
        'for beginners. It also filters indoor air toxins like formaldehyde.',
    careQuote: '"Thrives on neglect. The perfect plant for busy lives."',
    waterFrequency:   WaterFrequency.biweekly,
    lightRequirement: LightRequirement.lowLight,
    petSafety:        PetSafety.mildlyToxic,
    difficulty:       DifficultyLevel.beginner,
    humidity:         '30–50%',
    temperature:      '15–29°C',
    soilType:         'Sandy, well-draining cactus mix',
    fertilizer:       'Once in spring',
    commonName:       'Mother-in-Law\'s Tongue',
    origin:           'West Africa',
    isSustainable:    true,
    isRareCollection: false,
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
    description:
        'A cheerful, fast-growing plant that produces cascading "spiderettes". '
        'Completely safe for pets and children, it\'s one of the best air-purifying '
        'plants according to NASA\'s Clean Air Study.',
    careQuote: '"Safe for your furry friends. Grows with joy."',
    waterFrequency:   WaterFrequency.twiceWeekly,
    lightRequirement: LightRequirement.brightIndirect,
    petSafety:        PetSafety.safe,
    difficulty:       DifficultyLevel.beginner,
    humidity:         '40–60%',
    temperature:      '13–27°C',
    soilType:         'Moist, well-draining potting mix',
    fertilizer:       'Bi-monthly in growing season',
    commonName:       'Spider Plant',
    origin:           'South Africa',
    isSustainable:    true,
    isRareCollection: false,
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
    description:
        'The Peace Lily is a graceful plant with elegant white blooms. It thrives '
        'in low light and is exceptional at removing indoor air pollutants. '
        'It will even droop slightly to tell you when it needs water.',
    careQuote: '"It tells you when it\'s thirsty. A plant that communicates."',
    waterFrequency:   WaterFrequency.weekly,
    lightRequirement: LightRequirement.lowLight,
    petSafety:        PetSafety.toxic,
    difficulty:       DifficultyLevel.beginner,
    humidity:         '50–60%',
    temperature:      '18–30°C',
    soilType:         'Rich, loamy potting mix',
    fertilizer:       'Every 6 weeks in spring/summer',
    commonName:       'Peace Lily',
    origin:           'Tropical Americas',
    isSustainable:    false,
    isRareCollection: false,
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
    description:
        'Golden Pothos is the ultimate beginner plant — virtually indestructible. '
        'Its trailing vines with golden-green variegated leaves look stunning on '
        'shelves or hanging baskets. It tolerates low light and irregular watering.',
    careQuote: '"The plant that refuses to die. Perfect for every home."',
    waterFrequency:   WaterFrequency.weekly,
    lightRequirement: LightRequirement.lowLight,
    petSafety:        PetSafety.toxic,
    difficulty:       DifficultyLevel.beginner,
    humidity:         '50–70%',
    temperature:      '15–29°C',
    soilType:         'Any well-draining potting mix',
    fertilizer:       'Monthly in spring/summer',
    commonName:       'Devil\'s Ivy',
    origin:           'Southeast Asia',
    isSustainable:    true,
    isRareCollection: false,
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
    description:
        'The ZZ Plant is a glossy, architectural beauty that thrives in almost '
        'any condition. Its waxy, dark green leaves reflect light beautifully. '
        'It stores water in its rhizomes, making it extremely drought-tolerant.',
    careQuote: '"Glossy, bold, and nearly indestructible."',
    waterFrequency:   WaterFrequency.biweekly,
    lightRequirement: LightRequirement.lowLight,
    petSafety:        PetSafety.toxic,
    difficulty:       DifficultyLevel.beginner,
    humidity:         '40–50%',
    temperature:      '15–24°C',
    soilType:         'Well-draining cactus or succulent mix',
    fertilizer:       'Once in spring',
    commonName:       'Zanzibar Gem',
    origin:           'Eastern Africa',
    isSustainable:    false,
    isRareCollection: false,
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
    description:
        'The Rubber Plant is a bold, statement-making houseplant with large, '
        'glossy burgundy-green leaves. It grows tall and upright, making it '
        'ideal as a floor plant. Easy to care for and visually striking.',
    careQuote: '"Bold leaves, bold personality. A room-changer."',
    waterFrequency:   WaterFrequency.weekly,
    lightRequirement: LightRequirement.brightIndirect,
    petSafety:        PetSafety.toxic,
    difficulty:       DifficultyLevel.beginner,
    humidity:         '40–50%',
    temperature:      '15–24°C',
    soilType:         'Well-draining potting mix',
    fertilizer:       'Monthly in growing season',
    commonName:       'Rubber Fig',
    origin:           'South & Southeast Asia',
    isSustainable:    false,
    isRareCollection: false,
  ),
];
