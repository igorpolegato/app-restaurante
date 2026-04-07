import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/item_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailSheet extends StatefulWidget {
  final ItemModel item;

  const ProductDetailSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, ItemModel item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailSheet(item: item),
    );
  }

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  int _quantity = 1;
  final _obsController = TextEditingController();

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  void _addToCart() {
    context.read<CartProvider>().addItem(
          widget.item,
          quantity: _quantity,
          observation: _obsController.text.trim().isEmpty
              ? null
              : _obsController.text.trim(),
        );
    Navigator.of(context).pop();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${widget.item.name} adicionado ao carrinho'),
        backgroundColor: AppColors.brandBlack,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.item.price * _quantity;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.brandWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImage(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.item.categories.isNotEmpty)
                            Text(
                              widget.item.categoryNames.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            widget.item.name,
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandBlack,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'R\$ ${widget.item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandBlack,
                            ),
                          ),
                          if (widget.item.description != null &&
                              widget.item.description!.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              widget.item.description!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.6,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Text(
                            'Observação',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandBlack,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _obsController,
                            maxLines: 2,
                            style: GoogleFonts.inter(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Ex: sem cebola, bem passado...',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Quantity selector
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _QuantityButton(
                                icon: Icons.remove,
                                onTap: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  '$_quantity',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandBlack,
                                  ),
                                ),
                              ),
                              _QuantityButton(
                                icon: Icons.add,
                                onTap: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _addToCart,
                            child: Text(
                              'Adicionar  •  R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
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
  }

  Widget _buildImage() {
    final hasImage =
        widget.item.image != null && widget.item.image!.isNotEmpty;
    return SizedBox(
      height: 220,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: widget.item.image!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _imagePlaceholder(),
              errorWidget: (context, url, error) => _imagePlaceholder(),
            )
          : _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.brandYellow.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(Icons.restaurant, size: 64, color: AppColors.brandYellow),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.brandYellow : AppColors.brandGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? AppColors.brandBlack : AppColors.textMuted,
        ),
      ),
    );
  }
}
