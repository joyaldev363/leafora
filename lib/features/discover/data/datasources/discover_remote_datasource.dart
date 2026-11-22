import 'package:flutter/foundation.dart';
import '../../../../services/supabase_service.dart';
import '../models/discover_category_model.dart';
import '../models/plant_article_model.dart';
import '../models/plant_guide_model.dart';

/// Contract for Discover remote data interactions.
abstract interface class DiscoverRemoteDataSource {
  Future<List<DiscoverCategoryModel>> getCategories();
  Future<PlantGuideModel?> getFeaturedPlant();
  Future<List<PlantGuideModel>> getPopularPlants();
  Future<List<PlantArticleModel>> getPlantArticles({String? category});
  Future<List<PlantGuideModel>> getPlantGuides({String? category});
  Future<String> getDailyPlantTip();
  Future<Map<String, List<dynamic>>> searchContent(String query);
  Future<PlantArticleModel?> getArticleById(String id);
  Future<PlantGuideModel?> getPlantGuideById(String id);
}

/// Implementation of [DiscoverRemoteDataSource] querying Supabase with
/// resilient botanical fallback content for seamless offline and demo operation.
class DiscoverRemoteDataSourceImpl implements DiscoverRemoteDataSource {
  DiscoverRemoteDataSourceImpl();

  // ---------------------------------------------------------------------------
  // Botanical Offline / Demo Dataset
  // ---------------------------------------------------------------------------

  static const List<DiscoverCategoryModel> _defaultCategories = [
    DiscoverCategoryModel(id: 'cat_all', name: 'All'),
    DiscoverCategoryModel(id: 'cat_indoor', name: 'Indoor Plants'),
    DiscoverCategoryModel(id: 'cat_outdoor', name: 'Outdoor Plants'),
    DiscoverCategoryModel(id: 'cat_succulents', name: 'Succulents'),
    DiscoverCategoryModel(id: 'cat_flowering', name: 'Flowering Plants'),
    DiscoverCategoryModel(id: 'cat_low_maint', name: 'Low Maintenance'),
    DiscoverCategoryModel(id: 'cat_air_purifying', name: 'Air Purifying'),
  ];

  static const PlantGuideModel _featuredMonstera = PlantGuideModel(
    id: 'guide_monstera',
    plantName: 'Monstera Deliciosa',
    scientificName: 'Monstera deliciosa',
    imageUrl:
        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=1000&q=80',
    description:
        'Famous for its natural leaf holes (fenestrations), the Swiss Cheese Plant is an iconic tropical climber that brings a lush rainforest ambiance to any living room.',
    category: 'Indoor Plants',
    difficulty: 'Easy',
    watering: 'Water every 7–10 days when top 2 inches of soil feel dry.',
    sunlight: 'Medium to bright indirect sunlight. Avoid scorching direct sun.',
    soil: 'Peat-based potting soil mixed with perlite and orchid bark for maximum drainage.',
    fertilizer: 'Balanced liquid fertilizer (20-20-20) diluted to half-strength once a month in spring and summer.',
    careInstructions:
        'Provide a moss pole or trellis as it matures. Wipe the broad foliage monthly with a moist cloth to clear dust and enhance photosynthesis. Keep humidity around 50–60% for optimal fenestration development.',
  );

  static const List<PlantGuideModel> _popularPlants = [
    _featuredMonstera,
    PlantGuideModel(
      id: 'guide_peace_lily',
      plantName: 'Peace Lily',
      scientificName: 'Spathiphyllum wallisii',
      imageUrl:
          'https://images.unsplash.com/photo-1593691509543-c55fb32e7355?auto=format&fit=crop&w=800&q=80',
      description:
          'Elegant deep-green leaves paired with crisp white spathes make the Peace Lily a timeless home favorite that purifies indoor air.',
      category: 'Air Purifying',
      difficulty: 'Easy',
      watering: 'Water once a week. The plant politely droops its leaves when thirsty and bounces back rapidly.',
      sunlight: 'Prefers medium to low indirect light. Thrives away from harsh direct sun rays.',
      soil: 'Rich, loose potting mix that retains moisture while draining surplus water freely.',
      fertilizer: 'Feed bi-monthly during active spring blooming with balanced houseplant food.',
      careInstructions:
          'Keep soil consistently damp but never waterlogged. Sensitive to chlorine in tap water; allow water to sit out overnight before watering.',
    ),
    PlantGuideModel(
      id: 'guide_snake_plant',
      plantName: 'Snake Plant',
      scientificName: 'Dracaena trifasciata',
      imageUrl:
          'https://images.unsplash.com/photo-1599598425947-630b429d84bf?auto=format&fit=crop&w=800&q=80',
      description:
          'Virtually indestructible upright foliage featuring striking golden-yellow margins and silvery cross-banding patterns.',
      category: 'Low Maintenance',
      difficulty: 'Very Easy',
      watering: 'Every 2 to 3 weeks. Allow soil to dry out completely between waterings.',
      sunlight: 'Adapts to full sun, bright indirect light, and even low light office corners.',
      soil: 'Free-draining succulent or cactus mix containing pumice and coarse sand.',
      fertilizer: 'Light feeding once in mid-spring and once in mid-summer is plenty.',
      careInstructions:
          'The number one threat to a snake plant is overwatering. When in doubt, hold off on watering. Excellent bedside companion as it releases oxygen at night.',
    ),
    PlantGuideModel(
      id: 'guide_pothos',
      plantName: 'Golden Pothos',
      scientificName: 'Epipremnum aureum',
      imageUrl:
          'https://images.unsplash.com/photo-1596724806502-d9db86a7ff4b?auto=format&fit=crop&w=800&q=80',
      description:
          'Vigorous trailing vine with heart-shaped leaves marbled in creamy yellow, making it perfect for hanging baskets and bookshelf cascades.',
      category: 'Indoor Plants',
      difficulty: 'Easy',
      watering: 'Water every 7–10 days when top 50% of the soil has dried.',
      sunlight: 'Medium indirect light. Survives in low light, though leaf variegation may soften to solid green.',
      soil: 'Standard, high-quality indoor potting soil with good aeration.',
      fertilizer: 'Feed every 4–6 weeks throughout spring and summer with standard plant food.',
      careInstructions:
          'Prune long trailing stems occasionally to encourage bushier root crowns. Propagates effortlessly in a glass of water from stem cuttings.',
    ),
    PlantGuideModel(
      id: 'guide_aloe_vera',
      plantName: 'Aloe Vera',
      scientificName: 'Aloe barbadensis miller',
      imageUrl:
          'https://images.unsplash.com/photo-1509423350716-97f9360b4e09?auto=format&fit=crop&w=800&q=80',
      description:
          'A sculptural succulent with thick fleshy spears containing soothing gel celebrated worldwide for skin hydration and burns.',
      category: 'Succulents',
      difficulty: 'Easy',
      watering: 'Water deeply every 2–3 weeks in summer, reducing to once a month in winter.',
      sunlight: 'Bright direct to indirect sunlight. Enjoys sunny windowsills facing south or west.',
      soil: 'Porous, fast-draining cactus and succulent substrate in a terra cotta pot.',
      fertilizer: 'Minimal feeding needed. Once a year in spring with balanced 10-10-10 fertilizer.',
      careInstructions:
          'Ensure the pot has drainage holes. Never let water pool inside the central rosette to avoid crown rot.',
    ),
    PlantGuideModel(
      id: 'guide_rubber_plant',
      plantName: 'Rubber Plant',
      scientificName: 'Ficus elastica',
      imageUrl:
          'https://images.unsplash.com/photo-1545241047-6083a3684587?auto=format&fit=crop&w=800&q=80',
      description:
          'Bold architectural plant with glossy, oversized burgundy-green leaves that commands attention in interior decor.',
      category: 'Indoor Plants',
      difficulty: 'Moderate',
      watering: 'Water every 7–10 days. Keep soil moist but never soaked.',
      sunlight: 'Bright indirect light. Morning sun is beneficial, but protect from harsh afternoon rays.',
      soil: 'Well-aerated potting mix containing coco coir, perlite, and pine bark.',
      fertilizer: 'Feed every 4 weeks during spring and summer with water-soluble plant food.',
      careInstructions:
          'Avoid sudden drafts or temperature fluctuations which can trigger leaf drop. Wipe down leaves regularly to sustain high-gloss shine.',
    ),
  ];

  static const List<PlantArticleModel> _defaultArticles = [
    PlantArticleModel(
      id: 'art_1',
      title: 'How to Water Indoor Plants Without Overwatering',
      description:
          'Master the knuckle test, drainage checks, and root aeration to prevent the #1 cause of houseplant demise.',
      coverImageUrl:
          'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=1000&q=80',
      category: 'Watering & Routine',
      readingTime: '4 min read',
      createdAt: null, // Initialized in constructor
      content: '''
# The Art of Houseplant Hydration

Watering seems deceptively simple: your plant looks thirsty, so you pour water. Yet, overwatering remains responsible for more than 80% of houseplant casualties worldwide.

## 1. Understand Overwatering vs Too Much Water
Overwatering isn't about giving a plant too much water at once; it's about watering **too frequently**, preventing soil from drying and starving roots of oxygen. When soil stays perpetually wet, beneficial bacteria die, and fungal pathogens like *Pythium* trigger root rot.

## 2. The Golden Finger Test
Before you pick up the watering can:
- Insert your index finger two inches into the potting medium.
- If you feel moisture or soil sticks to your skin, wait 2 to 3 days.
- If it feels dry and powdery throughout, it is time for a thorough drink.

## 3. The Soak & Drain Technique
Take your plant to the sink or shower. Slowly soak the root ball until water flows out through the drainage holes. Allow it to drain completely for 15 minutes before returning it to its decorative saucer. Never let roots sit in standing pools of runoff.

## 4. Seasonal Adjustments
Plants drink significantly more during the warm, high-light days of spring and summer. In late autumn and winter, plant metabolism slows, sunlight dims, and watering frequency should be cut nearly in half.
''',
    ),
    PlantArticleModel(
      id: 'art_2',
      title: 'Understanding Sunlight: Direct, Indirect, and Low Light',
      description:
          'Decode your window orientations and learn how to provide each species with optimal foot-candles of light.',
      coverImageUrl:
          'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1000&q=80',
      category: 'Sunlight & Climate',
      readingTime: '5 min read',
      createdAt: null,
      content: '''
# Sunlight Decoded for Plant Parents

Light is the engine that drives photosynthesis and carbohydrate production. Without proper photon energy, no amount of fertilizer or watering will keep your foliage flourishing.

## The Window Compass
- **South-Facing Windows:** Maximum intensity. High direct sunlight for 5–8 hours. Ideal for Succulents, Cacti, Strelitzia, and Citrus.
- **East-Facing Windows:** Gentle, cooling morning sun that warms foliage without scorching. Perfect for Monstera, Ficus, and Ferns.
- **West-Facing Windows:** Intense late afternoon sun. Great for Sun-lovers, but thin-leaved tropicals may need sheer curtains.
- **North-Facing Windows:** Gentle, diffuse ambient light with no direct rays. Ideal for Snake Plants, ZZ Plants, and Chinese Evergreens.

## The Shadow Test
Hold your hand 12 inches above a piece of white paper near your plant:
- **Sharp, crisp shadow:** Bright direct sun.
- **Soft, blurred outline:** Medium to bright indirect light (the tropical sweet spot).
- **Faint, barely discernible shadow:** Low light.
''',
    ),
    PlantArticleModel(
      id: 'art_3',
      title: 'How to Choose and Blend the Perfect Potting Soil',
      description:
          'Learn why garden dirt suffocates indoor roots and how to craft well-draining, nutrient-rich substrates.',
      coverImageUrl:
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=1000&q=80',
      category: 'Soil & Repotting',
      readingTime: '6 min read',
      createdAt: null,
      content: '''
# Building the Ideal Root Environment

Potting mix isn't just "dirt" in a plastic container; it is a carefully engineered living matrix that anchors roots, holds moisture, and allows oxygen to circulate freely.

## Why Never to Use Outdoor Garden Soil
Garden soil contains heavy clay, silts, weed seeds, and pest larvae. When confined to an indoor pot, it compacts like concrete, suffocating roots and choking off drainage.

## The Essential Components of a Great Mix
1. **Peat Moss or Coco Coir (40%):** Provides lightweight structure and retains vital moisture.
2. **Perlite or Pumice (30%):** Volcanic minerals that prevent compaction and create essential air pockets.
3. **Orchid Bark (20%):** Coarse organic matter that mimics the forest floor where epiphytes naturally thrive.
4. **Worm Castings (10%):** Nature's slow-release organic nutrient booster packed with beneficial microbes.
''',
    ),
    PlantArticleModel(
      id: 'art_4',
      title: 'Preventing and Treating Common Houseplant Pests',
      description:
          'Natural, chemical-free solutions for combating fungus gnats, spider mites, mealybugs, and scale.',
      coverImageUrl:
          'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=1000&q=80',
      category: 'Plant Health',
      readingTime: '5 min read',
      createdAt: null,
      content: '''
# Organic Pest Defense Strategies

Even the most attentive plant lovers eventually face unwelcome visitors. Early detection and swift, non-toxic intervention are your best allies.

## 1. Fungus Gnats
Small, fruit-fly-sized insects fluttering above soil. Their larvae feed on organic compost and delicate root hairs.
- **Solution:** Allow top 2 inches of soil to dry completely. Water with Mosquito Bits tea (*Bacillus thuringiensis*) and place yellow sticky traps at pot level.

## 2. Spider Mites
Tiny arachnids causing speckled yellow stippling and fine silken webbing under leaves.
- **Solution:** Isolate immediately. Wash foliage with lukewarm shower spray, then spray all leaf surfaces with a mixture of cold-pressed neem oil, water, and mild castile soap.

## 3. Mealybugs
Small cottony white patches nestled in stem joints and leaf nodes.
- **Solution:** Dab individual bugs with a cotton swab soaked in 70% isopropyl alcohol for instant control.
''',
    ),
    PlantArticleModel(
      id: 'art_5',
      title: 'Succulent Care: How to Keep Fleshy Leaves Plump',
      description:
          'Desert botanicals have unique survival adaptations. Discover the soak-and-dry watering technique and terra cotta advantages.',
      coverImageUrl:
          'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?auto=format&fit=crop&w=1000&q=80',
      category: 'Succulents',
      readingTime: '4 min read',
      createdAt: null,
      content: '''
# Mastering Desert Beauties Indoors

Succulents store water in their fleshy stems, leaves, and roots, making them drought champions. Caring for them is less about constant pampering and more about providing strong light and benign neglect.

## The Soak-and-Dry Rhythm
Never mist succulents; surface spritzing encourages weak, shallow roots. Instead, drench the soil completely until water flows freely, then ignore them until the pot feels lightweight and the soil is bone dry throughout.

## Why Terra Cotta Pots Matter
Unglazed clay is porous and breathes, allowing moisture to evaporate naturally through the pot walls. This significantly reduces the risk of root rot compared to glazed ceramic or plastic pots.
''',
    ),
    PlantArticleModel(
      id: 'art_6',
      title: 'Indoor Plant Fertilizing Guide: Demystifying N-P-K',
      description:
          'Fuel vigorous spring growth and vibrant foliage with this comprehensive houseplant nutrition guide.',
      coverImageUrl:
          'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?auto=format&fit=crop&w=1000&q=80',
      category: 'Fertilizer & Feeding',
      readingTime: '5 min read',
      createdAt: null,
      content: '''
# Houseplant Nutrition Demystified

Potting soil only contains enough natural nutrients to sustain a plant for 2 to 3 months. After that, supplementary feeding is essential to replenish micro and macronutrients.

## The N-P-K Code
- **Nitrogen (N):** Drives vigorous leafy growth and lush green chlorophyll production.
- **Phosphorus (P):** Strengthens root development and stimulates blooms and flowers.
- **Potassium (K):** Enhances cellular resilience, disease resistance, and water regulation.

## Golden Feeding Rules
1. Never fertilize dry soil—always hydrate roots first to prevent fertilizer salt burn.
2. Dilute commercial liquid fertilizers to half the manufacturer's recommended strength.
3. Pause all feeding during late autumn and winter when plants rest.
''',
    ),
  ];

  static const List<String> _dailyTips = [
    'Rotate your indoor plants a quarter turn each week to ensure balanced sunlight exposure and prevent lopsided growth.',
    'Dust broad leaves with a damp microfiber cloth monthly so they can capture maximum sunlight and photosynthesize efficiently.',
    'Always use room-temperature water. Icy cold tap water can shock tender tropical roots and trigger premature leaf drop.',
    'Cluster humidity-loving plants together; transpiration naturally creates a microclimate of higher ambient moisture around them.',
    'Yellowing lower leaves often indicate slight overwatering, while crispy brown tips are a telltale sign of dry air or underwatering.',
  ];

  // ---------------------------------------------------------------------------
  // Interface Implementations with Supabase + Fallback
  // ---------------------------------------------------------------------------

  @override
  Future<List<DiscoverCategoryModel>> getCategories() async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final res = await SupabaseService.instance.client
            .from('discover_categories')
            .select()
            .order('name');
        if (res.isNotEmpty) {
          return res.map((item) => DiscoverCategoryModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('DiscoverRemoteDataSource: Notice - Categories fallback ($e)');
    }
    return _defaultCategories;
  }

  @override
  Future<PlantGuideModel?> getFeaturedPlant() async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final res = await SupabaseService.instance.client
            .from('plant_guides')
            .select()
            .eq('is_featured', true)
            .maybeSingle();
        if (res != null) {
          return PlantGuideModel.fromJson(res);
        }
      }
    } catch (e) {
      debugPrint('DiscoverRemoteDataSource: Notice - Featured plant fallback ($e)');
    }
    return _featuredMonstera;
  }

  @override
  Future<List<PlantGuideModel>> getPopularPlants() async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final res = await SupabaseService.instance.client
            .from('plant_guides')
            .select()
            .limit(10);
        if (res.isNotEmpty) {
          return res.map((item) => PlantGuideModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('DiscoverRemoteDataSource: Notice - Popular plants fallback ($e)');
    }
    return _popularPlants;
  }

  @override
  Future<List<PlantArticleModel>> getPlantArticles({String? category}) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        var query = SupabaseService.instance.client.from('plant_articles').select();
        if (category != null && category != 'All') {
          query = query.eq('category', category);
        }
        final res = await query;
        if (res.isNotEmpty) {
          return res.map((item) => PlantArticleModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('DiscoverRemoteDataSource: Notice - Articles fallback ($e)');
    }

    if (category == null || category == 'All') {
      return _defaultArticles;
    }
    return _defaultArticles
        .where((a) =>
            a.category.toLowerCase().contains(category.toLowerCase()) ||
            category.toLowerCase().contains(a.category.toLowerCase()))
        .toList();
  }

  @override
  Future<List<PlantGuideModel>> getPlantGuides({String? category}) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        var query = SupabaseService.instance.client.from('plant_guides').select();
        if (category != null && category != 'All') {
          query = query.eq('category', category);
        }
        final res = await query;
        if (res.isNotEmpty) {
          return res.map((item) => PlantGuideModel.fromJson(item)).toList();
        }
      }
    } catch (e) {
      debugPrint('DiscoverRemoteDataSource: Notice - Guides fallback ($e)');
    }

    if (category == null || category == 'All') {
      return _popularPlants;
    }
    return _popularPlants
        .where((g) =>
            g.category.toLowerCase().contains(category.toLowerCase()) ||
            category.toLowerCase().contains(g.category.toLowerCase()))
        .toList();
  }

  @override
  Future<String> getDailyPlantTip() async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final res = await SupabaseService.instance.client
            .from('daily_plant_tips')
            .select('tip')
            .limit(1)
            .maybeSingle();
        if (res != null && res['tip'] != null) {
          return res['tip'] as String;
        }
      }
    } catch (e) {
      debugPrint('DiscoverRemoteDataSource: Notice - Daily tip fallback ($e)');
    }
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _dailyTips[dayOfYear % _dailyTips.length];
  }

  @override
  Future<Map<String, List<dynamic>>> searchContent(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      return {'articles': [], 'guides': []};
    }

    final matchedArticles = _defaultArticles.where((a) {
      return a.title.toLowerCase().contains(clean) ||
          a.description.toLowerCase().contains(clean) ||
          a.category.toLowerCase().contains(clean);
    }).toList();

    final matchedGuides = _popularPlants.where((g) {
      return g.plantName.toLowerCase().contains(clean) ||
          (g.scientificName?.toLowerCase().contains(clean) ?? false) ||
          g.description.toLowerCase().contains(clean) ||
          g.category.toLowerCase().contains(clean);
    }).toList();

    return {
      'articles': matchedArticles,
      'guides': matchedGuides,
    };
  }

  @override
  Future<PlantArticleModel?> getArticleById(String id) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final res = await SupabaseService.instance.client
            .from('plant_articles')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (res != null) {
          return PlantArticleModel.fromJson(res);
        }
      }
    } catch (e) {
      debugPrint('DiscoverRemoteDataSource: Notice - Article by ID fallback ($e)');
    }
    return _defaultArticles.where((a) => a.id == id).firstOrNull;
  }

  @override
  Future<PlantGuideModel?> getPlantGuideById(String id) async {
    try {
      if (SupabaseService.instance.isInitialized) {
        final res = await SupabaseService.instance.client
            .from('plant_guides')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (res != null) {
          return PlantGuideModel.fromJson(res);
        }
      }
    } catch (e) {
      debugPrint('DiscoverRemoteDataSource: Notice - Guide by ID fallback ($e)');
    }
    return _popularPlants.where((g) => g.id == id).firstOrNull;
  }
}
