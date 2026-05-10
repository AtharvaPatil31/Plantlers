import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../home/domain/entities/plant_entity.dart';

part 'plant_detail_widgets.dart';

const _green      = Color(0xFF00450D);
const _greenLight = Color(0xFF1B5E20);
const _greenMuted = Color(0xFFE8F5E9);

class PlantDetailPage extends StatelessWidget {
  final PlantEntity plant;
  const PlantDetailPage({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CartBloc>(),
      child: _PlantDetailView(plant: plant),
    );
  }
}

class _PlantDetailView extends StatelessWidget {
  final PlantEntity plant;
  const _PlantDetailView({required this.plant});

  @override
  Widget build(BuildContext context) {
    final isDark    = context.isDarkMode;
    final bg        = isDark ? AppColors.darkBackground : const Color(0xFFFAFAF5);
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A);
    final subColor  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartLoaded) {
          context.showSnackBar('${plant.name} added to cart 🌿');
        }
        if (state is CartError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        extendBodyBehindAppBar: true,
        appBar: _DetailAppBar(
          isDark: isDark,
        ),
        body: CustomScrollView(
          slivers: [
            // ── Hero image ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _HeroImage(plant: plant, isDark: isDark),
            ),

            // ── Collection badge + name + price ─────────────────────────
            SliverToBoxAdapter(
              child: _PlantHeader(
                plant:     plant,
                isDark:    isDark,
                textColor: textColor,
                subColor:  subColor,
              ),
            ),

            // ── Care quote ───────────────────────────────────────────────
            if (plant.careQuote != null)
              SliverToBoxAdapter(
                child: _CareQuote(
                  quote:  plant.careQuote!,
                  isDark: isDark,
                ),
              ),

            // ── Description ──────────────────────────────────────────────
            if (plant.description != null)
              SliverToBoxAdapter(
                child: _Description(
                  text:      plant.description!,
                  isDark:    isDark,
                  textColor: textColor,
                  subColor:  subColor,
                ),
              ),

            // ── Care details grid ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _CareDetailsGrid(plant: plant, isDark: isDark),
            ),

            // ── Delivery info ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _DeliveryInfo(isDark: isDark),
            ),

            // Bottom padding for sticky bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),

        // ── Sticky bottom bar ────────────────────────────────────────────
        bottomNavigationBar: _AddToCartBar(
          plant:  plant,
          isDark: isDark,
        ),
      ),
    );
  }
}
