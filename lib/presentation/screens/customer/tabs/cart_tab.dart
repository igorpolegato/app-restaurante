import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/session_provider.dart';

class CartTab extends StatelessWidget {
  final VoidCallback onOrderPlaced;

  const CartTab({super.key, required this.onOrderPlaced});

  Future<void> _placeOrder(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final session = context.read<SessionProvider>();
    final orders = context.read<OrderProvider>();

    if (cart.isEmpty || session.customerId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmar pedido?',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Total: R\$ ${cart.total.toStringAsFixed(2).replaceAll('.', ',')}\n\nDeseja confirmar o pedido?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(100, 42),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await orders.createOrder(
      customerId: session.customerId!,
      items: cart.toOrderPayload(),
    );

    if (!context.mounted) return;

    if (success) {
      cart.clear();
      onOrderPlaced();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido realizado com sucesso! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orders.error ?? 'Erro ao fazer pedido'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isSubmitting = context.watch<OrderProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.brandGray,
      appBar: AppBar(
        title: Text(
          'Carrinho',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: AppColors.brandBlack),
        ),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => context.read<CartProvider>().clear(),
              child: Text(
                'Limpar',
                style: GoogleFonts.inter(
                    color: Colors.red.shade600, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: cart.isEmpty ? _buildEmpty() : _buildCart(context, cart),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _buildCheckoutBar(context, cart, isSubmitting),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.brandYellow.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                size: 40, color: AppColors.brandYellow),
          ),
          const SizedBox(height: 16),
          Text(
            'Seu carrinho está vazio',
            style: GoogleFonts.montserrat(
                fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione itens do cardápio para começar',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCart(BuildContext context, CartProvider cart) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.items.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final ci = cart.items[index];
        return _CartItemCard(cartItem: ci);
      },
    );
  }

  Widget _buildCheckoutBar(
      BuildContext context, CartProvider cart, bool isSubmitting) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.brandWhite,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: GoogleFonts.montserrat(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              Text(
                'R\$ ${cart.total.toStringAsFixed(2).replaceAll('.', ',')}',
                style: GoogleFonts.montserrat(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: isSubmitting ? null : () => _placeOrder(context),
            child: isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.brandBlack,
                    ),
                  )
                : Text(
                    'Fazer Pedido  •  ${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'itens'}',
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem cartItem;

  const _CartItemCard({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: _buildImage(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.item.name,
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      'R\$ ${cartItem.item.price.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _QuantityControl(
                quantity: cartItem.quantity,
                onDecrement: () => cart.decrement(cartItem.item.id),
                onIncrement: () => cart.increment(cartItem.item.id),
              ),
            ],
          ),
          if (cartItem.observation != null && cartItem.observation!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.brandGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '📝 ${cartItem.observation}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textMuted),
              ),
              Text(
                'R\$ ${cartItem.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final hasImage =
        cartItem.item.image != null && cartItem.item.image!.isNotEmpty;
    if (hasImage) {
      return CachedNetworkImage(
        imageUrl: cartItem.item.image!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(),
        errorWidget: (context, url, error) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.brandYellow.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(Icons.restaurant, size: 24, color: AppColors.brandYellow),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Btn(icon: Icons.remove, onTap: onDecrement),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '$quantity',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _Btn(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.brandYellow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.brandBlack),
      ),
    );
  }
}
