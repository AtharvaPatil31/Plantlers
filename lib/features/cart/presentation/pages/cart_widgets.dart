// cart_widgets.dart — all widget classes used by cart_page.dart
part of 'cart_page.dart';

// ── App bar ───────────────────────────────────────────────────────────────────
class _CartAppBar extends StatelessWidget {
  final bool isDark;
  final int  itemCount;
  const _CartAppBar({required this.isDark, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : _green;
    final subColor  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY CART',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$itemCount ${itemCount == 1 ? "item" : "items"}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          if (itemCount > 0)
            GestureDetector(
              onTap: () => _showClearDialog(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkTextSecondary : _green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Clear Cart',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
        content: Text('Remove all items from your cart?',
            style: GoogleFonts.dmSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CartBloc>().add(const CartCleared());
            },
            child: Text('Clear',
                style: GoogleFonts.dmSans(
                    color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Promo banner ──────────────────────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  final CartEntity             cart;
  final bool                   isDark;
  final TextEditingController  controller;
  final CartLoaded             state;

  const _PromoBanner({
    required this.cart,
    required this.isDark,
    required this.controller,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final hasPromo = cart.appliedPromoCode != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: hasPromo
          ? _AppliedPromo(
              code:     cart.appliedPromoCode!,
              discount: cart.promoDiscount,
              isDark:   isDark,
            )
          : _PromoInput(
              controller: controller,
              isDark:     isDark,
              isLoading:  state.isPromoLoading,
              error:      state.promoError,
            ),
    );
  }
}

class _AppliedPromo extends StatelessWidget {
  final String code;
  final double discount;
  final bool   isDark;

  const _AppliedPromo({
    required this.code,
    required this.discount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'PROMO CODE $code APPLIED  −₹${discount.toStringAsFixed(0)}',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                context.read<CartBloc>().add(const CartPromoRemoved()),
            child: const Icon(Icons.close_rounded,
                color: Colors.white70, size: 18),
          ),
        ],
      ),
    );
  }
}

class _PromoInput extends StatelessWidget {
  final TextEditingController controller;
  final bool                  isDark;
  final bool                  isLoading;
  final String?               error;

  const _PromoInput({
    required this.controller,
    required this.isDark,
    required this.isLoading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final fieldBg   = isDark ? AppColors.darkSurfaceVariant : Colors.white;
    final hintColor = isDark ? AppColors.darkTextHint : AppColors.textHint;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: error != null
                  ? Colors.red
                  : isDark
                      ? AppColors.darkDivider
                      : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.local_offer_outlined, size: 18, color: _green),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: textColor,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    hintStyle: GoogleFonts.dmSans(
                        fontSize: 13, color: hintColor),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () {
                        final code = controller.text.trim();
                        if (code.isNotEmpty) {
                          context
                              .read<CartBloc>()
                              .add(CartPromoApplied(code));
                        }
                      },
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Apply',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: GoogleFonts.dmSans(fontSize: 11, color: Colors.red),
          ),
        ],
      ],
    );
  }
}

// ── Cart item tile ────────────────────────────────────────────────────────────
class _CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final bool           isDark;

  const _CartItemTile({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg    = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A);
    final subColor  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) =>
          context.read<CartBloc>().add(CartItemRemoved(item.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
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
            // Plant image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.plant.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: _greenMuted,
                  child: const Icon(Icons.eco_outlined,
                      color: _green, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.plant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.plant.tag} · ${item.potSize}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 11, color: subColor),
                  ),
                  const SizedBox(height: 8),
                  // Qty stepper
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove_rounded,
                        onTap: () => context.read<CartBloc>().add(
                              CartQuantityUpdated(
                                cartItemId: item.id,
                                quantity:   item.quantity - 1,
                              ),
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add_rounded,
                        isAdd: true,
                        onTap: () => context.read<CartBloc>().add(
                              CartQuantityUpdated(
                                cartItemId: item.id,
                                quantity:   item.quantity + 1,
                              ),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${item.lineTotal.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : _green,
                  ),
                ),
                if (item.quantity > 1) ...[
                  const SizedBox(height: 2),
                  Text(
                    '₹${item.plant.priceInr.toStringAsFixed(0)} each',
                    style: GoogleFonts.dmSans(fontSize: 10, color: subColor),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final bool         isAdd;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.isAdd = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bg = isAdd
        ? _green
        : isDark
            ? AppColors.darkSurfaceVariant
            : _greenMuted;
    final iconColor = isAdd || isDark ? Colors.white : _green;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}

// ── Delivery badge ────────────────────────────────────────────────────────────
class _DeliveryBadge extends StatelessWidget {
  final bool isFree;
  final bool isDark;

  const _DeliveryBadge({required this.isFree, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFree
              ? _green.withValues(alpha: 0.3)
              : isDark
                  ? AppColors.darkDivider
                  : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isFree ? _green : Colors.orange,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isFree ? 'FREE' : 'PAID',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFree
                      ? 'Free delivery on this order'
                      : 'Delivery charges apply',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  isFree
                      ? 'Estimated delivery: 2–3 business days'
                      : 'Add items worth ₹${(999 - 0).toStringAsFixed(0)} more for free delivery',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.local_shipping_outlined,
            color: isFree ? _green : Colors.orange,
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ── Order summary ─────────────────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final CartEntity cart;
  final bool       isDark;
  final Color      cardBg, textColor, subColor, divColor;

  const _OrderSummary({
    required this.cart,
    required this.isDark,
    required this.cardBg,
    required this.textColor,
    required this.subColor,
    required this.divColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label:     'Subtotal (${cart.itemCount} items)',
            value:     '₹${cart.subtotal.toStringAsFixed(0)}',
            textColor: textColor,
            subColor:  subColor,
          ),
          if (cart.appliedPromoCode != null) ...[
            const SizedBox(height: 10),
            _SummaryRow(
              label:      'Promo (${cart.appliedPromoCode})',
              value:      '−₹${cart.promoDiscount.toStringAsFixed(0)}',
              textColor:  textColor,
              subColor:   subColor,
              valueColor: isDark ? Colors.white : _green,
            ),
          ],
          const SizedBox(height: 10),
          _SummaryRow(
            label:      'Delivery',
            value:      cart.isFreeDelivery
                ? 'Free'
                : '₹${cart.deliveryCharge.toStringAsFixed(0)}',
            textColor:  textColor,
            subColor:   subColor,
            valueColor: cart.isFreeDelivery ? (isDark ? Colors.white : _green) : null,
          ),
          const SizedBox(height: 12),
          Divider(color: divColor, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                '₹${cart.total.toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : _green,
                ),
              ),
            ],
          ),
          if (cart.savings > 0) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _greenMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "You're saving ₹${cart.savings.toStringAsFixed(0)} on this order",
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : _green,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String  label, value;
  final Color   textColor, subColor;
  final Color?  valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.subColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(fontSize: 13, color: subColor)),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? textColor,
          ),
        ),
      ],
    );
  }
}

// ── Suggestions row ───────────────────────────────────────────────────────────
class _SuggestionsRow extends StatelessWidget {
  final List<PlantEntity> plants;
  final bool              isDark;

  const _SuggestionsRow({required this.plants, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: plants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) =>
            _SuggestionCard(plant: plants[i], isDark: isDark),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final PlantEntity plant;
  final bool        isDark;

  const _SuggestionCard({required this.plant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg    = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PlantDetailPage(plant: plant)),
      ),
      child: Container(
        width: 140,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                plant.imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  color: _greenMuted,
                  child: const Icon(Icons.eco_outlined,
                      color: _green, size: 32),
                ),
              ),
            ),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${plant.priceInr.toStringAsFixed(0)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : _green,
                        ),
                      ),
                      // ── Reactive add / stepper ──────────────────────
                      BlocBuilder<CartBloc, CartState>(
                        buildWhen: (prev, curr) {
                          if (prev is CartLoaded && curr is CartLoaded) {
                            final pq = prev.cart.items
                                .where((i) => i.id == plant.id)
                                .fold(0, (s, i) => s + i.quantity);
                            final cq = curr.cart.items
                                .where((i) => i.id == plant.id)
                                .fold(0, (s, i) => s + i.quantity);
                            return pq != cq;
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
                            // + button — add to cart
                            return GestureDetector(
                              onTap: () => context
                                  .read<CartBloc>()
                                  .add(CartItemAdded(plant: plant)),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _green,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.add_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            );
                          }

                          // Mini stepper — − qty +
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => context.read<CartBloc>().add(
                                      CartQuantityUpdated(
                                        cartItemId: plant.id,
                                        quantity:   qty - 1,
                                      ),
                                    ),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurfaceVariant
                                        : _greenMuted,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Icon(Icons.remove_rounded,
                                      size: 13,
                                      color: isDark ? Colors.white : _green),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5),
                                child: Text(
                                  '$qty',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : _green,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.read<CartBloc>().add(
                                      CartItemAdded(plant: plant),
                                    ),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _green,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(Icons.add_rounded,
                                      size: 13, color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
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

// ── Place order sticky bar ────────────────────────────────────────────────────
class _PlaceOrderBar extends StatelessWidget {
  final CartEntity cart;
  final bool       isDark;

  const _PlaceOrderBar({required this.cart, required this.isDark});

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
            onTap: () => _confirmOrder(context),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_green, _greenLight],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL AMOUNT',
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            color: Colors.white70,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          '₹${cart.total.toStringAsFixed(0)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'PLACE ORDER',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CartBloc>(),
        child: _OrderConfirmSheet(cart: cart, isDark: isDark),
      ),
    );
  }
}

// ── Order confirm bottom sheet ────────────────────────────────────────────────
class _OrderConfirmSheet extends StatelessWidget {
  final CartEntity cart;
  final bool       isDark;

  const _OrderConfirmSheet({required this.cart, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg        = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A);
    final subColor  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.shopping_bag_outlined, color: _green, size: 40),
          const SizedBox(height: 12),
          Text(
            'Confirm Order',
            style: GoogleFonts.dmSerifDisplay(fontSize: 24, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            '${cart.itemCount} items · ₹${cart.total.toStringAsFixed(0)} total',
            style: GoogleFonts.dmSans(fontSize: 14, color: subColor),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.read<CartBloc>().add(const CartCleared());
            },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_green, _greenLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                'Place Order',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Continue Shopping',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: subColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty cart ────────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  final bool          isDark;
  final VoidCallback? onBrowsePlants;
  const _EmptyCart({required this.isDark, this.onBrowsePlants});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A);
    final subColor  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: _greenMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 48, color: _green),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 24, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some plants to get started on your botanical journey',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: subColor, height: 1.5),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onBrowsePlants,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Browse Plants',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order success view ────────────────────────────────────────────────────────
class _OrderSuccessView extends StatelessWidget {
  final bool isDark;
  const _OrderSuccessView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg        = isDark ? AppColors.darkBackground : const Color(0xFFFAFAF5);
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF1A1A1A);
    final subColor  = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: _greenMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    size: 52, color: _green),
              ),
              const SizedBox(height: 24),
              Text(
                'Order Placed!',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 28, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Your plants are on their way.\nEstimated delivery: 2–3 business days.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                    fontSize: 14, color: subColor, height: 1.5),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => context
                    .read<CartBloc>()
                    .add(const CartLoadRequested()),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Continue Shopping',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
