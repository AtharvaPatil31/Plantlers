import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../home/domain/entities/plant_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../bloc/cart_bloc.dart';
import '../../../plant_detail/presentation/pages/plant_detail_page.dart';

part 'cart_widgets.dart';

const _green      = Color(0xFF00450D);
const _greenLight = Color(0xFF1B5E20);
const _greenMuted = Color(0xFFE8F5E9);

class CartPage extends StatelessWidget {
  final VoidCallback? onBrowsePlants;
  const CartPage({super.key, this.onBrowsePlants});

  @override
  Widget build(BuildContext context) {
    return _CartView(onBrowsePlants: onBrowsePlants);
  }
}

// Triggers CartLoadRequested once when the cart tab is first shown
class _CartView extends StatefulWidget {
  final VoidCallback? onBrowsePlants;
  const _CartView({this.onBrowsePlants});

  @override
  State<_CartView> createState() => _CartViewState();
}

class _CartViewState extends State<_CartView> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return _CartBody(onBrowsePlants: widget.onBrowsePlants);
  }
}

class _CartBody extends StatelessWidget {
  final VoidCallback? onBrowsePlants;
  const _CartBody({this.onBrowsePlants});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bg     = isDark ? AppColors.darkBackground : const Color(0xFFFAFAF5);

    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartOrderPlaced) {
          context.showSnackBar('Order placed successfully! 🌿');
        }
        if (state is CartError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        if (state is CartLoading || state is CartInitial) {
          return Scaffold(
            backgroundColor: bg,
            body: const Center(
              child: CircularProgressIndicator(color: _green),
            ),
          );
        }

        if (state is CartOrderPlaced) {
          return _OrderSuccessView(isDark: isDark);
        }

        if (state is CartLoaded) {
          return _CartContent(
            state:          state,
            isDark:         isDark,
            onBrowsePlants: onBrowsePlants,
          );
        }

        return Scaffold(backgroundColor: bg, body: const SizedBox.shrink());
      },
    );
  }
}

// ── Main cart content ─────────────────────────────────────────────────────────
class _CartContent extends StatefulWidget {
  final CartLoaded    state;
  final bool          isDark;
  final VoidCallback? onBrowsePlants;

  const _CartContent({
    required this.state,
    required this.isDark,
    this.onBrowsePlants,
  });

  @override
  State<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<_CartContent> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart    = widget.state.cart;
    final isDark  = widget.isDark;
    final bg      = isDark ? AppColors.darkBackground : const Color(0xFFFAFAF5);
    final cardBg  = isDark ? AppColors.darkSurface    : Colors.white;
    final textColor  = isDark ? AppColors.darkTextPrimary   : const Color(0xFF1A1A1A);
    final subColor   = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final divColor   = isDark ? AppColors.darkDivider       : AppColors.divider;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ───────────────────────────────────────────────────
            _CartAppBar(isDark: isDark, itemCount: cart.itemCount),

            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: cart.isEmpty
                  ? _EmptyCart(isDark: isDark, onBrowsePlants: widget.onBrowsePlants)
                  : CustomScrollView(
                      slivers: [
                        // Promo banner
                        SliverToBoxAdapter(
                          child: _PromoBanner(
                            cart:       cart,
                            isDark:     isDark,
                            controller: _promoController,
                            state:      widget.state,
                          ),
                        ),

                        // Cart items
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _CartItemTile(
                                item:   cart.items[i],
                                isDark: isDark,
                              ),
                              childCount: cart.items.length,
                            ),
                          ),
                        ),

                        // Free delivery badge
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: _DeliveryBadge(
                              isFree: cart.isFreeDelivery,
                              isDark: isDark,
                            ),
                          ),
                        ),

                        // Order summary
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: _OrderSummary(
                              cart:     cart,
                              isDark:   isDark,
                              cardBg:   cardBg,
                              textColor: textColor,
                              subColor:  subColor,
                              divColor:  divColor,
                            ),
                          ),
                        ),

                        // You may also like
                        if (widget.state.suggestions.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                              child: Text(
                                'You may also like',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 22,
                                  color: isDark ? Colors.white : _green,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _SuggestionsRow(
                              plants: widget.state.suggestions,
                              isDark: isDark,
                            ),
                          ),
                        ],

                        // Bottom padding for sticky bar
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),

      // ── Sticky bottom bar ─────────────────────────────────────────────────
      bottomNavigationBar: cart.isEmpty
          ? null
          : _PlaceOrderBar(cart: cart, isDark: isDark),
    );
  }
}
