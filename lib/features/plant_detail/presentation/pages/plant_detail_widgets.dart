// plant_detail_widgets.dart
part of 'plant_detail_page.dart';

// ── App bar ───────────────────────────────────────────────────────────────────
class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;

  const _DetailAppBar({required this.isDark});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : _green,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ── Hero image ────────────────────────────────────────────────────────────────
class _HeroImage extends StatelessWidget {
  final PlantEntity plant;
  final bool        isDark;

  const _HeroImage({required this.plant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screenH = context.screenHeight;

    return SizedBox(
      height: screenH * 0.48,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.darkSurfaceVariant,
                        AppColors.darkBackground,
                      ]
                    : [
                        const Color(0xFFEEF5EC),
                        const Color(0xFFFAFAF5),
                      ],
              ),
            ),
          ),

          // Plant image — slightly oversized for drama
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.network(
              plant.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.eco_outlined,
                  size: 100,
                  color: _green.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

          // Bottom fade into background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDark
                        ? AppColors.darkBackground
                        : const Color(0xFFFAFAF5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plant header — collection badge, name, price, sustainable tag ─────────────
class _PlantHeader extends StatelessWidget {
  final PlantEntity plant;
  final bool        isDark;
  final Color       textColor, subColor;

  const _PlantHeader({
    required this.plant,
    required this.isDark,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collection badge
          if (plant.isRareCollection)
            Text(
              'RARE COLLECTION',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _green,
                letterSpacing: 2,
              ),
            ),
          if (plant.isRareCollection) const SizedBox(height: 6),

          // Plant name
          Text(
            plant.name,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 34,
              color: isDark ? textColor : _green,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),

          // Scientific name
          Text(
            plant.subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: subColor,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 14),

          // Price row + sustainable badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹${plant.priceInr.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _green,
                ),
              ),
              const SizedBox(width: 12),
              if (plant.isSustainable)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.eco_rounded,
                          size: 12, color: _green),
                      const SizedBox(width: 4),
                      Text(
                        'SUSTAINABLE CHOICE',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _green,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Care quote ────────────────────────────────────────────────────────────────
class _CareQuote extends StatelessWidget {
  final String quote;
  final bool   isDark;

  const _CareQuote({required this.quote, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : const Color(0xFFF0F4EE),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppColors.darkDivider
                : _green.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          quote,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: isDark
                ? AppColors.darkTextSecondary
                : const Color(0xFF41493E),
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ── Description ───────────────────────────────────────────────────────────────
class _Description extends StatelessWidget {
  final String text;
  final bool   isDark;
  final Color  textColor, subColor;

  const _Description({
    required this.text,
    required this.isDark,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESCRIPTION',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: subColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: subColor,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Care details grid ─────────────────────────────────────────────────────────
class _CareDetailsGrid extends StatelessWidget {
  final PlantEntity plant;
  final bool        isDark;

  const _CareDetailsGrid({required this.plant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final rows = <_DetailRow>[];

    if (plant.humidity != null)
      rows.add(_DetailRow('Humidity', plant.humidity!, Icons.water_outlined));
    if (plant.temperature != null)
      rows.add(_DetailRow('Temperature', plant.temperature!, Icons.thermostat_outlined));
    if (plant.soilType != null)
      rows.add(_DetailRow('Soil', plant.soilType!, Icons.grass_outlined));
    if (plant.fertilizer != null)
      rows.add(_DetailRow('Fertilizer', plant.fertilizer!, Icons.science_outlined));
    if (plant.origin != null)
      rows.add(_DetailRow('Origin', plant.origin!, Icons.public_outlined));
    if (plant.commonName != null)
      rows.add(_DetailRow('Common Name', plant.commonName!, Icons.label_outline_rounded));

    if (rows.isEmpty) return const SizedBox.shrink();

    final cardBg  = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A);
    final subColor  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor  = isDark ? AppColors.darkDivider : AppColors.divider;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CARE GUIDE',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: subColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: rows.asMap().entries.map((entry) {
                final i   = entry.key;
                final row = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _greenMuted,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(row.icon,
                                size: 17, color: _green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              row.label,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: subColor,
                              ),
                            ),
                          ),
                          Text(
                            row.value,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < rows.length - 1)
                      Divider(
                          height: 1,
                          indent: 62,
                          endIndent: 16,
                          color: divColor),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow {
  final String   label, value;
  final IconData icon;
  const _DetailRow(this.label, this.value, this.icon);
}

// ── Delivery info ─────────────────────────────────────────────────────────────
class _DeliveryInfo extends StatelessWidget {
  final bool isDark;
  const _DeliveryInfo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined,
              size: 16, color: _green),
          const SizedBox(width: 8),
          Text(
            'Ships tomorrow if ordered in next 2h',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add to cart sticky bar ────────────────────────────────────────────────────
class _AddToCartBar extends StatelessWidget {
  final PlantEntity plant;
  final bool        isDark;

  const _AddToCartBar({
    required this.plant,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final navBg = isDark ? AppColors.darkSurface : Colors.white;

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: GestureDetector(
            onTap: () {
              context.read<CartBloc>().add(
                    CartItemAdded(plant: plant),
                  );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_green, _greenLight],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'ADD TO CART',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
