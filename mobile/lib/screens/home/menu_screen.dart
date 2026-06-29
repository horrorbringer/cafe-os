import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';
import '../../models/menu_item.dart';
import '../../models/cart_item.dart';
import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../home/branch_select_screen.dart';

class MenuScreen extends StatefulWidget {
  final Function(int menuItemId) onItemTap;
  final VoidCallback onCartTap;
  final VoidCallback onSearchTap;

  const MenuScreen({
    super.key,
    required this.onItemTap,
    required this.onCartTap,
    required this.onSearchTap,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedTab = 0;
  List<MenuItem>? _cachedFeatured;

  void _handleItemAdd(MenuItem item, CartProvider cart) {
    final inCart = cart.items.any((i) => i.menuItemId == item.menuItemId);
    if (inCart) {
      final index = cart.items.indexWhere((i) => i.menuItemId == item.menuItemId);
      if (index >= 0) {
        cart.updateQty(index, cart.items[index].qty + 1);
      }
    } else if (item.variants.isNotEmpty) {
      widget.onItemTap(item.menuItemId);
    } else {
      cart.addItem(CartItem(
        menuItemId: item.menuItemId,
        name: item.name,
        imageUrl: item.imageUrl,
        basePrice: item.displayPrice,
      ));
    }
  }

  void _handleItemRemove(MenuItem item, CartProvider cart) {
    final index = cart.items.indexWhere((i) => i.menuItemId == item.menuItemId);
    if (index >= 0) {
      if (cart.items[index].qty <= 1) {
        cart.removeItem(index);
      } else {
        cart.updateQty(index, cart.items[index].qty - 1);
      }
    }
  }

  int _cartQty(MenuItem item, CartProvider cart) {
    return cart.items.where((i) => i.menuItemId == item.menuItemId).fold(0, (sum, i) => sum + i.qty);
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final cart = context.watch<CartProvider>();
    final categories = menu.menuCategories;
    final showCart = !cart.isEmpty;

    // Cache featured items when menu data changes
    final allItems = categories.expand((cat) => cat.items).toList();
    if (_cachedFeatured == null || _cachedFeatured!.length != allItems.length) {
      final shuffled = List<MenuItem>.from(allItems)..shuffle();
      _cachedFeatured = shuffled.take(4).toList();
    }

    final selectedCategory = _selectedTab < categories.length ? categories[_selectedTab] : null;
    final items = selectedCategory?.items ?? [];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/cafe_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.background.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshMenu,
              color: AppTheme.primary,
              backgroundColor: Colors.white,
              child: menu.isLoading
                  ? _buildShimmer()
                  : categories.isEmpty
                      ? _buildEmptyMenuState()
                      : CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            SliverToBoxAdapter(
                              child: _buildMenuHeader(context, menu, cart),
                            ),
                            SliverToBoxAdapter(
                              child: _buildCategoryTabs(categories),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 128),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.72,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final item = items[index];
                                    return _MenuItemCard(
                                      item: item,
                                      cartQty: _cartQty(item, cart),
                                      onTap: () => widget.onItemTap(item.menuItemId),
                                      onAdd: () => _handleItemAdd(item, cart),
                                      onRemove: () => _handleItemRemove(item, cart),
                                    );
                                  },
                                  childCount: items.length,
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          ],
        ),
      );
  }

  Future<void> _refreshMenu() async {
    _cachedFeatured = null;
    await context.read<MenuProvider>().loadBranches();
    if (mounted) {
      await context.read<AuthProvider>().refreshProfile();
    }
  }

  Widget _buildCategoryTabs(List<CategoryWithItems> categories) {
    return Container(
      color: AppTheme.surface.withValues(alpha: 0.96),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(categories.length, (i) {
            final isSelected = i == _selectedTab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppTheme.surfaceLight.withValues(alpha: 0.3),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    categories[i].name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCartBar(CartProvider cart) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onCartTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${cart.itemCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'View Cart',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '\$${cart.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuHeader(BuildContext context, MenuProvider menu, CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BranchSelectScreen(
                          onBranchSelected: (branch) {
                            context.read<MenuProvider>().selectBranch(branch);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                menu.selectedBranch?.name ?? 'Select Branch',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: AppTheme.primary.withValues(alpha: 0.8),
                            ),
                          ],
                        ),
                        if (menu.selectedBranch?.location != null)
                          Text(
                            menu.selectedBranch!.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.onSearchTap,
                icon: const Icon(Icons.search, color: AppTheme.textPrimary),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: widget.onCartTap,
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildLoyaltyPulse(context),
        const SizedBox(height: 24),
        if (_cachedFeatured != null && _cachedFeatured!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Featured for you',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          _buildFeaturedSection(_cachedFeatured!),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildEmptyMenuState() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.coffee_outlined,
                  size: 52,
                  color: AppTheme.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No items yet',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our barista is crafting something new.\nCheck back soon!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoyaltyPulse(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final customer = auth.customer;
    if (customer == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.08),
            AppTheme.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${customer.loyaltyPoints} Points',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${customer.membershipLevel} Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Gold Rewards',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppTheme.primary.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(List<MenuItem> featured) {
    if (featured.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final item = featured[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: item.imageUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(item.imageUrl!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.35),
                        BlendMode.darken,
                      ),
                    )
                  : null,
              color: AppTheme.primaryLight.withValues(alpha: 0.3),
              gradient: item.imageUrl == null
                  ? LinearGradient(
                      colors: [AppTheme.primaryLight, AppTheme.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: InkWell(
              onTap: () => widget.onItemTap(item.menuItemId),
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'From \$${item.displayPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: AppTheme.surfaceLight,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 128),
          child: Column(
          children: [
            // Header placeholder
            Container(
              height: 24,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            // Categories bar placeholder
            Container(
              height: 36,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            // 2-column grid placeholders
            Row(
              children: [
                Expanded(child: _shimmerCard()),
                const SizedBox(width: 16),
                Expanded(child: _shimmerCard()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _shimmerCard()),
                const SizedBox(width: 16),
                Expanded(child: _shimmerCard()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _shimmerCard()),
                const SizedBox(width: 16),
                Expanded(child: _shimmerCard()),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          // Content area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 14,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int cartQty;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItemCard({
    required this.item,
    required this.cartQty,
    required this.onTap,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: item.isAvailable ? onTap : null,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: SizedBox(
                    width: double.infinity,
                    child: Hero(
                      tag: 'item_image_${item.menuItemId}',
                      child: item.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                color: AppTheme.surfaceLight,
                                child: const Center(child: Icon(Icons.coffee, color: AppTheme.textSecondary)),
                              ),
                              errorWidget: (_, _, _) => Container(
                                color: AppTheme.surfaceLight,
                                child: const Center(child: Icon(Icons.coffee, color: AppTheme.textSecondary)),
                              ),
                            )
                          : Container(
                              color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                              child: const Center(child: Icon(Icons.coffee, size: 36, color: AppTheme.textSecondary)),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.variants.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.variants.map((v) => v.size).join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.primary.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${item.displayPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            if (item.isAvailable)
                              cartQty > 0
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _QtyButton(
                                            icon: Icons.remove_rounded,
                                            onTap: onRemove,
                                          ),
                                          SizedBox(
                                            width: 28,
                                            child: Text(
                                              '$cartQty',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                          ),
                                          _QtyButton(
                                            icon: Icons.add_rounded,
                                            onTap: onAdd,
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primary.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                                    ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!item.isAvailable)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SOLD OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
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

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 18),
      ),
    );
  }
}
