import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/menu_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/customer/category_filter_bar.dart';
import '../../../widgets/customer/product_card.dart';
import '../../../widgets/customer/product_detail_sheet.dart';

class MenuTab extends StatefulWidget {
  final VoidCallback onGoToCart;

  const MenuTab({super.key, required this.onGoToCart});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        context.read<MenuProvider>().clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final menu = context.watch<MenuProvider>();

    return Scaffold(
      backgroundColor: AppColors.brandGray,
      appBar: AppBar(
        backgroundColor: AppColors.brandWhite,
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.inter(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Buscar produtos...',
                  hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: context.read<MenuProvider>().setSearch,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${session.customerName}! 👋',
                    style: GoogleFonts.montserrat(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlack,
                    ),
                  ),
                  Text(
                    'Mesa ${session.mesa}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            color: AppColors.brandBlack,
          ),
        ],
      ),
      body: menu.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.brandYellow))
          : menu.error != null
              ? _buildError(menu)
              : _buildContent(menu),
    );
  }

  Widget _buildError(MenuProvider menu) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 56, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              menu.error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<MenuProvider>().loadData(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(MenuProvider menu) {
    final items = menu.filteredItems;

    return RefreshIndicator(
      color: AppColors.brandYellow,
      onRefresh: () => context.read<MenuProvider>().loadData(),
      child: CustomScrollView(
        slivers: [
          // Category filter
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (menu.categories.isNotEmpty)
                  CategoryFilterBar(
                    categories: menu.categories,
                    selectedId: menu.selectedCategoryId,
                    onSelected: context.read<MenuProvider>().setCategory,
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Products grid
          items.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum produto encontrado',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, index) {
                        final item = items[index];
                        return ProductCard(
                          item: item,
                          onTap: () =>
                              ProductDetailSheet.show(context, item),
                          onAdd: () {
                            context.read<CartProvider>().addItem(item);
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('${item.name} adicionado!'),
                                backgroundColor: AppColors.brandBlack,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'Ver carrinho',
                                  textColor: AppColors.brandYellow,
                                  onPressed: widget.onGoToCart,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: items.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
