import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../../domain/entities/explore_section_entity.dart';
import '../bloc/explore_bloc.dart';

const _green      = Color(0xFF00450D);
const _greenLight = Color(0xFF1B5E20);
const _greenMuted = Color(0xFFE8F5E9);

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExploreBloc>()..add(const ExploreLoadRequested()),
      child: const _ExploreView(),
    );
  }
}

class _ExploreView extends StatefulWidget {
  const _ExploreView();

  @override
  State<_ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<_ExploreView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bg     = isDark ? AppColors.darkBackground : const Color(0xFFFAFAF5);

    return Scaffold(
      backgroundColor: bg,
      body: BlocBuilder<ExploreBloc, ExploreState>(
        builder: (context, state) {
          if (state is ExploreLoading || state is ExploreInitial) {
            return const Center(
              child: CircularProgressIndicator(color: _green),
            );
          }
          if (state is ExploreError) {
            return Center(
              child: Text(state.message,
                  style: GoogleFonts.dmSans(color: Colors.red)),
            );
          }
          if (state is ExploreLoaded) {
            return _ExploreContent(
              state:            state,
              searchController: _searchController,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Main scrollable content ───────────────────────────────────────────────────
class _ExploreContent extends StatelessWidget {
  final ExploreLoaded      state;
  final TextEditingController searchController;

  const _ExploreContent({
    required this.state,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final data      = state.data;
    final isDark    = context.isDarkMode;
    final textColor = isDark ? AppColors.darkTextPrimary   : _green;
    final subColor  = isDark ? AppColors.darkTextSecondary : const Color(0xFF41493E);
    final searchBg  = isDark ? AppColors.darkFieldBg       : Colors.white;
    final hintColor = isDark ? AppColors.darkTextHint      : const Color(0xFF9E9E9E);
    final chipBg    = isDark ? AppColors.darkSurfaceVariant: const Color(0xFFEEEDE9);

    final showFiltered = data.filteredPlants.isNotEmpty ||
        data.searchQuery.isNotEmpty ||
        data.activeFilter != null;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 32,
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find your perfect plant companion',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: subColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Search bar ───────────────────────────────────────────
                  _SearchBar(
                    controller: searchController,
                    bg:         searchBg,
                    hintColor:  hintColor,
                    textColor:  subColor,
                    isDark:     isDark,
                    suggestions: state.searchSuggestions,
                    hintIndex:   state.hintIndex,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── Category pills ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _CategoryPills(
              activeFilter: data.activeFilter,
              isDark:       isDark,
              chipBg:       chipBg,
              subColor:     subColor,
            ),
          ),

          if (showFiltered) ...[
            // ── Filtered results ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.searchQuery.isNotEmpty
                          ? 'Results for "${data.searchQuery}"'
                          : data.activeFilter != null
                              ? _categoryLabel(data.activeFilter!)
                              : 'Filtered Plants',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        context
                            .read<ExploreBloc>()
                            .add(const ExploreClearFilter());
                      },
                      child: Text(
                        'Clear',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: _green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: data.filteredPlants.isEmpty
                  ? SliverToBoxAdapter(
                      child: _EmptyState(isDark: isDark),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _NewArrivalTile(
                          plant:  data.filteredPlants[i],
                          isDark: isDark,
                        ),
                        childCount: data.filteredPlants.length,
                      ),
                    ),
            ),
          ] else ...[
            // ── Shop by Room ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Shop by Room',
                isDark: isDark,
                actionLabel: 'View All',
              ),
            ),
            SliverToBoxAdapter(
              child: _RoomGrid(isDark: isDark),
            ),

            // ── Trending Now ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'Trending Now', isDark: isDark),
            ),
            SliverToBoxAdapter(
              child: _TrendingRow(plants: data.trendingPlants, isDark: isDark),
            ),

            // ── New Arrivals ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionHeader(title: 'New Arrivals', isDark: isDark),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _NewArrivalTile(
                    plant:  data.newArrivals[i],
                    isDark: isDark,
                  ),
                  childCount: data.newArrivals.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _categoryLabel(PlantCategory cat) {
    switch (cat) {
      case PlantCategory.petFriendly: return 'Pet Friendly Plants';
      case PlantCategory.lowLight:    return 'Low Light Plants';
      case PlantCategory.office:      return 'Office Plants';
      case PlantCategory.tropical:    return 'Tropical Plants';
      case PlantCategory.airPurifier: return 'Air Purifying Plants';
    }
  }
}

// ── Search bar — identical to home, with animated typing hint ────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Color bg, hintColor, textColor;
  final bool isDark;
  final List<String> suggestions;
  final int hintIndex;

  const _SearchBar({
    required this.controller,
    required this.bg,
    required this.hintColor,
    required this.textColor,
    required this.isDark,
    required this.suggestions,
    required this.hintIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: AppColors.darkDivider) : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // ── Actual text field ─────────────────────────────────────────
          TextField(
            controller: controller,
            onChanged: (q) =>
                context.read<ExploreBloc>().add(ExploreSearchChanged(q)),
            style: GoogleFonts.dmSans(fontSize: 14, color: textColor),
            decoration: InputDecoration(
              hintText: null,
              prefixIcon:
                  Icon(Icons.search_rounded, color: hintColor, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                  left: 48, right: 12, top: 14, bottom: 14),
            ),
          ),
          // ── Animated hint — visible only when field is empty ──────────
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isNotEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(left: 48),
                child: suggestions.isEmpty
                    ? Text('Search plants, care tips...',
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: hintColor))
                    : _AnimatedSearchHint(
                        suggestions: suggestions,
                        hintIndex:   hintIndex,
                        hintColor:   hintColor,
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Category pills — exact same style as home screen ─────────────────────────
class _CategoryPills extends StatelessWidget {
  final PlantCategory? activeFilter;
  final bool isDark;
  final Color chipBg;
  final Color subColor;

  const _CategoryPills({
    this.activeFilter,
    required this.isDark,
    required this.chipBg,
    required this.subColor,
  });

  static const _categories = [
    (null,                      'All'),
    (PlantCategory.petFriendly, 'Pet Friendly'),
    (PlantCategory.lowLight,    'Low Light'),
    (PlantCategory.office,      'Office'),
    (PlantCategory.tropical,    'Tropical'),
    (PlantCategory.airPurifier, 'Air Purifier'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final (cat, label) = _categories[i];
          final isActive = cat == activeFilter;
          return GestureDetector(
            onTap: () => context
                .read<ExploreBloc>()
                .add(ExploreCategorySelected(cat)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? _green : chipBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _green : Colors.transparent,
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : subColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String  title;
  final String? actionLabel;
  final bool    isDark;

  const _SectionHeader({
    required this.title,
    required this.isDark,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : _green;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 20,
              color: textColor,
              height: 1.1,
            ),
          ),
          if (actionLabel != null)
            Text(
              actionLabel!,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: _green,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Care level section ────────────────────────────────────────────────────────
class _CareLevelSection extends StatelessWidget {
  final bool isDark;
  const _CareLevelSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Easy — full width hero card
          _CareLevelCard(
            level:    CareLevel.easy,
            isDark:   isDark,
            isHero:   true,
          ),
          const SizedBox(height: 10),
          // Medium + Expert — side by side
          Row(
            children: [
              Expanded(
                child: _CareLevelCard(
                  level:  CareLevel.medium,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CareLevelCard(
                  level:  CareLevel.expert,
                  isDark: isDark,
                  isExpert: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CareLevelCard extends StatelessWidget {
  final CareLevel level;
  final bool      isDark;
  final bool      isHero;
  final bool      isExpert;

  const _CareLevelCard({
    required this.level,
    required this.isDark,
    this.isHero   = false,
    this.isExpert = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isExpert
        ? _green
        : isDark
            ? AppColors.darkSurfaceVariant
            : _greenMuted;

    final textColor = isExpert
        ? Colors.white
        : isDark
            ? AppColors.darkTextPrimary
            : _green;

    final subColor = isExpert
        ? Colors.white.withValues(alpha: 0.7)
        : isDark
            ? AppColors.darkTextSecondary
            : _green.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: () => context
          .read<ExploreBloc>()
          .add(ExploreCareLevelSelected(level)),
      child: Container(
        height: isHero ? 90 : 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    level.label,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: isHero ? 22 : 18,
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ),
            // Decorative leaf icon
            Icon(
              Icons.eco_rounded,
              size: isHero ? 36 : 28,
              color: isExpert
                  ? Colors.white.withValues(alpha: 0.3)
                  : _green.withValues(alpha: 0.15),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Room grid ─────────────────────────────────────────────────────────────────
class _RoomGrid extends StatelessWidget {
  final bool isDark;
  const _RoomGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
        children: RoomType.values
            .map((room) => _RoomCard(room: room, isDark: isDark))
            .toList(),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomType room;
  final bool     isDark;
  const _RoomCard({required this.room, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<ExploreBloc>().add(ExploreRoomSelected(room)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              room.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: _greenMuted),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            // Label
            Positioned(
              left: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.label,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trending row ──────────────────────────────────────────────────────────────
class _TrendingRow extends StatelessWidget {
  final List<PlantEntity> plants;
  final bool              isDark;
  const _TrendingRow({required this.plants, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: plants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => _TrendingCard(plant: plants[i], isDark: isDark),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final PlantEntity plant;
  final bool        isDark;
  const _TrendingCard({required this.plant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  plant.imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(height: 130, color: _greenMuted),
                ),
                // HOT badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'HOT',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plant.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${plant.priceInr.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── New arrival tile ──────────────────────────────────────────────────────────
class _NewArrivalTile extends StatelessWidget {
  final PlantEntity plant;
  final bool        isDark;
  const _NewArrivalTile({required this.plant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              plant.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: 72, height: 72, color: _greenMuted),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plant.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant.tag,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _green.withValues(alpha: 0.7),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${plant.priceInr.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: isDark
                ? AppColors.darkTextHint
                : const Color(0xFFBDBDBD),
          ),
          const SizedBox(height: 12),
          Text(
            'No plants found',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or category',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextHint
                  : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated search hint — types/erases keywords like home screen ─────────────
class _AnimatedSearchHint extends StatefulWidget {
  final List<String> suggestions;
  final int          hintIndex;
  final Color        hintColor;

  const _AnimatedSearchHint({
    required this.suggestions,
    required this.hintIndex,
    required this.hintColor,
  });

  @override
  State<_AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<_AnimatedSearchHint> {
  String _displayed = '';
  Timer? _typeTimer;
  Timer? _cycleTimer;
  int    _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(_AnimatedSearchHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hintIndex != widget.hintIndex) {
      _reset();
      _startTyping();
    }
  }

  void _reset() {
    _typeTimer?.cancel();
    _cycleTimer?.cancel();
    _charIndex = 0;
    if (mounted) setState(() => _displayed = '');
  }

  void _startTyping() {
    final keyword = widget.suggestions.isEmpty
        ? 'Search plants...'
        : widget.suggestions[widget.hintIndex % widget.suggestions.length];

    _typeTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_charIndex < keyword.length) {
        setState(() {
          _displayed = keyword.substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        t.cancel();
        _cycleTimer = Timer(const Duration(milliseconds: 1800), () {
          if (!mounted) return;
          _eraseText(keyword);
        });
      }
    });
  }

  void _eraseText(String keyword) {
    _typeTimer = Timer.periodic(const Duration(milliseconds: 35), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_displayed.isNotEmpty) {
        setState(() =>
            _displayed = _displayed.substring(0, _displayed.length - 1));
      } else {
        t.cancel();
        if (mounted) {
          context.read<ExploreBloc>().add(const ExploreAdvanceSearchHint());
        }
      }
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cycleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _displayed,
          style: GoogleFonts.dmSans(fontSize: 14, color: widget.hintColor),
        ),
        const SizedBox(width: 2),
        _BlinkingCursor(color: widget.hintColor),
      ],
    );
  }
}

// ── Blinking cursor ───────────────────────────────────────────────────────────
class _BlinkingCursor extends StatefulWidget {
  final Color color;
  const _BlinkingCursor({required this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 1.5,
        height: 18,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
