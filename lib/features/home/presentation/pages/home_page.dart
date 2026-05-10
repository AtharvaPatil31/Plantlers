import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/plant_entity.dart';
import '../bloc/home_bloc.dart';
import '../../../explore/presentation/pages/explore_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../plant_detail/presentation/pages/plant_detail_page.dart';

// ── Brand green — same in both modes (intentional brand colour) ───────────────
const _green = Color(0xFF00450D);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CartBloc>()..add(const CartLoadRequested()),
      child: BlocProvider(
        create: (_) => sl<HomeBloc>()..add(const HomeLoadPlants()),
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _navIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _navIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFFAFAF5);

    return Scaffold(
      backgroundColor: bg,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (i) => setState(() => _navIndex = i),
        children: [
          const _KeepAlivePage(child: _HomeTab()),
          const _KeepAlivePage(child: ExplorePage()),
          _KeepAlivePage(child: CartPage(onBrowsePlants: () => _onNavTap(0))),
          const _KeepAlivePage(child: _PlaceholderTab(label: 'Profile', icon: Icons.person_outline_rounded)),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ── Keep-alive wrapper — prevents PageView from destroying tab state ──────────
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return widget.child;
  }
}

// ── Home tab ──────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // ── Semantic colour tokens resolved per mode ──────────────────────────
    final bg         = isDark ? AppColors.darkBackground    : const Color(0xFFFAFAF5);
    final cardBg     = isDark ? AppColors.darkSurface       : Colors.white;
    final searchBg   = isDark ? AppColors.darkFieldBg       : Colors.white;
    final chipBg     = isDark ? AppColors.darkSurfaceVariant: const Color(0xFFEEEDE9);
    final iconColor  = isDark ? AppColors.primaryLight      : _green;
    final titleColor = isDark ? AppColors.darkTextPrimary   : _green;
    final subColor   = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final hintColor  = isDark ? AppColors.darkTextHint      : AppColors.textHint;
    final textColor  = isDark ? AppColors.darkTextPrimary   : AppColors.textPrimary;
    final navBg      = isDark ? AppColors.darkSurface       : Colors.white;
    final divColor   = isDark ? AppColors.darkDivider       : AppColors.divider;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.menu_rounded, color: iconColor, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Plantlers',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: titleColor,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.notifications_none_rounded,
                          color: iconColor, size: 26),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(14),
                        border: isDark
                            ? Border.all(color: AppColors.darkDivider)
                            : null,
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
                          // ── Actual text field ───────────────────────────
                          TextField(
                            controller: _searchController,
                            onChanged: (v) => context
                                .read<HomeBloc>()
                                .add(HomeSearchPlants(v)),
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: textColor),
                            decoration: InputDecoration(
                              hintText: null,
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: hintColor, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(
                                  left: 48, right: 12, top: 14, bottom: 14),
                            ),
                          ),
                          // ── Animated hint — visible only when field empty
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchController,
                            builder: (_, value, __) {
                              if (value.text.isNotEmpty) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(left: 48),
                                child: BlocBuilder<HomeBloc, HomeState>(
                                  buildWhen: (p, c) =>
                                      c is HomeLoaded &&
                                      (p is! HomeLoaded ||
                                          (p).hintIndex !=
                                              (c).hintIndex),
                                  builder: (context, state) {
                                    final suggestions = state is HomeLoaded
                                        ? state.searchSuggestions
                                        : <String>[];
                                    final idx = state is HomeLoaded
                                        ? state.hintIndex
                                        : 0;
                                    if (suggestions.isEmpty) {
                                      return Text(
                                        'Search plants...',
                                        style: GoogleFonts.dmSans(
                                            fontSize: 14, color: hintColor),
                                      );
                                    }
                                    return _AnimatedSearchHint(
                                      suggestions: suggestions,
                                      hintIndex: idx,
                                      hintColor: hintColor,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Hero text ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Botanical Living',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: titleColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bring intentional greenery into your\nspace with our curated studio selection.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: subColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Category chips ─────────────────────────────────────────────
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                final active =
                    state is HomeLoaded ? state.activeCategory : null;
                return SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _CategoryChip(
                        label: 'All',
                        isActive: active == null,
                        chipBg: chipBg,
                        subColor: subColor,
                        onTap: () => context
                            .read<HomeBloc>()
                            .add(const HomeFilterByCategory(null)),
                      ),
                      _CategoryChip(
                        label: 'Pet Friendly',
                        isActive: active == PlantCategory.petFriendly,
                        chipBg: chipBg,
                        subColor: subColor,
                        onTap: () => context.read<HomeBloc>().add(
                              const HomeFilterByCategory(
                                  PlantCategory.petFriendly),
                            ),
                      ),
                      _CategoryChip(
                        label: 'Low Light',
                        isActive: active == PlantCategory.lowLight,
                        chipBg: chipBg,
                        subColor: subColor,
                        onTap: () => context.read<HomeBloc>().add(
                              const HomeFilterByCategory(
                                  PlantCategory.lowLight),
                            ),
                      ),
                      _CategoryChip(
                        label: 'Office',
                        isActive: active == PlantCategory.office,
                        chipBg: chipBg,
                        subColor: subColor,
                        onTap: () => context.read<HomeBloc>().add(
                              const HomeFilterByCategory(PlantCategory.office),
                            ),
                      ),
                      _CategoryChip(
                        label: 'Tropical',
                        isActive: active == PlantCategory.tropical,
                        chipBg: chipBg,
                        subColor: subColor,
                        onTap: () => context.read<HomeBloc>().add(
                              const HomeFilterByCategory(
                                  PlantCategory.tropical),
                            ),
                      ),
                      _CategoryChip(
                        label: 'Air Purifier',
                        isActive: active == PlantCategory.airPurifier,
                        chipBg: chipBg,
                        subColor: subColor,
                        onTap: () => context.read<HomeBloc>().add(
                              const HomeFilterByCategory(
                                  PlantCategory.airPurifier),
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // ── Plant grid ─────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading || state is HomeInitial) {
                    return Center(
                      child: CircularProgressIndicator(color: iconColor),
                    );
                  }
                  if (state is HomeError) {
                    return Center(
                      child: Text(state.message,
                          style: GoogleFonts.dmSans(color: Colors.red)),
                    );
                  }
                  if (state is HomeLoaded) {
                    if (state.plants.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco_outlined,
                                size: 48, color: hintColor),
                            const SizedBox(height: 12),
                            Text(
                              'No plants found',
                              style: GoogleFonts.dmSans(
                                  color: subColor, fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: state.plants.length,
                      itemBuilder: (_, i) => _PlantCard(
                        plant: state.plants[i],
                        cardBg: cardBg,
                        textColor: textColor,
                        subColor: subColor,
                        isDark: isDark,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated search hint (types keywords like Amazon/Flipkart) ────────────────
class _AnimatedSearchHint extends StatefulWidget {
  final List<String> suggestions;
  final int hintIndex;
  final Color hintColor;

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
  int _charIndex = 0;
  bool _typing = true;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(_AnimatedSearchHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    // BLoC advanced to next keyword — restart animation
    if (oldWidget.hintIndex != widget.hintIndex) {
      _reset();
      _startTyping();
    }
  }

  void _reset() {
    _typeTimer?.cancel();
    _cycleTimer?.cancel();
    _charIndex = 0;
    _typing = true;
    if (mounted) setState(() => _displayed = '');
  }

  void _startTyping() {
    final keyword = widget.suggestions.isEmpty
        ? 'Search plants...'
        : widget.suggestions[widget.hintIndex % widget.suggestions.length];

    // Type one character every 60ms
    _typeTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_charIndex < keyword.length) {
        setState(() {
          _displayed = keyword.substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        t.cancel();
        // Pause 1.8s fully typed, then tell BLoC to advance
        _cycleTimer = Timer(const Duration(milliseconds: 1800), () {
          if (!mounted) return;
          // Erase character by character
          _eraseText(keyword);
        });
      }
    });
  }

  void _eraseText(String keyword) {
    _typeTimer = Timer.periodic(const Duration(milliseconds: 35), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_displayed.isNotEmpty) {
        setState(() => _displayed = _displayed.substring(0, _displayed.length - 1));
      } else {
        t.cancel();
        // Tell BLoC to move to next keyword — BLoC owns the index
        if (mounted) {
          context.read<HomeBloc>().add(const HomeAdvanceSearchHint());
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
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: widget.hintColor,
          ),
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

// ── Category chip ─────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color chipBg;
  final Color subColor;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.chipBg,
    required this.subColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  }
}

// ── Plant card ────────────────────────────────────────────────────────────────
class _PlantCard extends StatelessWidget {
  final PlantEntity plant;
  final Color cardBg;
  final Color textColor;
  final Color subColor;
  final bool isDark;

  const _PlantCard({
    required this.plant,
    required this.cardBg,
    required this.textColor,
    required this.subColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final imagePlaceholderBg =
        isDark ? AppColors.darkSurfaceVariant : const Color(0xFFEEEDE9);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlantDetailPage(plant: plant),
        ),
      ),
      child: Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ────────────────────────────────────────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    plant.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: imagePlaceholderBg,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? AppColors.primaryLight : _green,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: imagePlaceholderBg,
                      child: Icon(Icons.eco_outlined,
                          color: isDark ? AppColors.primaryLight : _green,
                          size: 40),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Info ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        plant.name,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '₹${plant.priceInr.toStringAsFixed(0)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : _green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  plant.tag,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // ── Cart button — reactive via CartBloc ───────────────
                BlocBuilder<CartBloc, CartState>(
                  buildWhen: (prev, curr) {
                    // Only rebuild when cart items change
                    if (prev is CartLoaded && curr is CartLoaded) {
                      final prevQty = prev.cart.items
                          .where((i) => i.id == plant.id)
                          .fold(0, (s, i) => s + i.quantity);
                      final currQty = curr.cart.items
                          .where((i) => i.id == plant.id)
                          .fold(0, (s, i) => s + i.quantity);
                      return prevQty != currQty;
                    }
                    return curr is CartLoaded || curr is CartInitial;
                  },
                  builder: (context, state) {
                    final qty = state is CartLoaded
                        ? state.cart.items
                            .where((i) => i.id == plant.id)
                            .fold(0, (s, i) => s + i.quantity)
                        : 0;

                    if (qty == 0) {
                      // ── Add to Cart button ──────────────────────────
                      return SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () => context
                              .read<CartBloc>()
                              .add(CartItemAdded(plant: plant)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Add to Cart',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }

                    // ── Quantity stepper ────────────────────────────────
                    return SizedBox(
                      height: 30,
                      child: Row(
                        children: [
                          // Minus
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.read<CartBloc>().add(
                                    CartQuantityUpdated(
                                      cartItemId: plant.id,
                                      quantity:   qty - 1,
                                    ),
                                  ),
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceVariant
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.remove_rounded,
                                  size: 16,
                                  color: isDark ? Colors.white : _green,
                                ),
                              ),
                            ),
                          ),
                          // Quantity
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '$qty',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          // Plus
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.read<CartBloc>().add(
                                    CartItemAdded(plant: plant),
                                  ),
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: _green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ), // Container
    ); // GestureDetector
  }
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final navBg = isDark ? AppColors.darkSurface : Colors.white;
    final activeColor = isDark ? AppColors.primaryLight : _green;
    final inactiveColor =
        isDark ? AppColors.darkTextHint : AppColors.textHint;

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                outlinedIcon: Icons.home_outlined,
                label: 'HOME',
                isActive: currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.explore_rounded,
                outlinedIcon: Icons.explore_outlined,
                label: 'EXPLORE',
                isActive: currentIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.shopping_cart_rounded,
                outlinedIcon: Icons.shopping_cart_outlined,
                label: 'CART',
                isActive: currentIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                outlinedIcon: Icons.person_outline_rounded,
                label: 'PROFILE',
                isActive: currentIndex == 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData outlinedIcon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? icon : outlinedIcon,
                key: ValueKey(isActive),
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder tabs ──────────────────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final String label;
  final IconData icon;

  const _PlaceholderTab({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 48,
              color: isDark ? AppColors.darkTextHint : AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            '$label — coming soon',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
