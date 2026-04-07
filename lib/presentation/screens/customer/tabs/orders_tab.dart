import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../../data/models/order_model.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  double _grandTotal(List<OrderModel> orders) =>
      orders.fold(0.0, (sum, o) => sum + o.total);

  Future<void> _confirmCheckout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Finalizar Conta',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text(
          'Deseja encerrar sua sessão e finalizar a conta?\nVocê será redirecionado para a tela inicial.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Finalizar',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SessionProvider>().clearSession();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/identify');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    final session = context.watch<SessionProvider>();
    final hasOrders = orders.customerOrders.isNotEmpty;
    final grandTotal = _grandTotal(orders.customerOrders);

    return Scaffold(
      backgroundColor: AppColors.brandGray,
      appBar: AppBar(
        title: Text(
          'Meus Pedidos',
          style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold, color: AppColors.brandBlack),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: session.customerId == null
                ? null
                : () => context
                    .read<OrderProvider>()
                    .loadCustomerOrders(session.customerId!),
          ),
        ],
      ),
      body: orders.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.brandYellow))
          : !hasOrders
              ? _buildEmpty()
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.brandYellow,
                        onRefresh: () => context
                            .read<OrderProvider>()
                            .loadCustomerOrders(session.customerId!),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: orders.customerOrders.length,
                          separatorBuilder: (_, i) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) =>
                              _OrderCard(order: orders.customerOrders[index]),
                        ),
                      ),
                    ),
                    _CheckoutBar(
                      total: grandTotal,
                      onCheckout: () => _confirmCheckout(context),
                    ),
                  ],
                ),
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
            child: const Icon(Icons.receipt_long_outlined,
                size: 40, color: AppColors.brandYellow),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum pedido ainda',
            style: GoogleFonts.montserrat(
                fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Faça seu primeiro pedido pelo cardápio',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;

  const _CheckoutBar({required this.total, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.brandWhite,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total da conta',
                  style: GoogleFonts.montserrat(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              Text(
                'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandBlack),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.receipt_long),
              label: Text('Finalizar Conta',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.brandWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _statusIcon(order.status),
                      color: _statusColor(order.status),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido #${order.id.toString().padLeft(5, '0')}',
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${order.items.length} ${order.items.length == 1 ? 'item' : 'itens'}  •  R\$ ${order.total.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: order.status, label: order.statusLabel),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items list
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.brandBlack,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: GoogleFonts.inter(fontSize: 13),
                            ),
                          ),
                          Text(
                            'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 20),
                  // Timeline
                  const SizedBox(height: 4),
                  Text(
                    'Status do pedido',
                    style: GoogleFonts.montserrat(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _StatusTimeline(status: order.status),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.statusPending;
      case 'preparing':
        return AppColors.statusPreparing;
      case 'ready':
        return AppColors.statusReady;
      case 'done':
        return AppColors.statusDone;
      default:
        return AppColors.statusPending;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_top_outlined;
      case 'preparing':
        return Icons.outdoor_grill_outlined;
      case 'ready':
        return Icons.check_circle_outline;
      case 'done':
        return Icons.done_all;
      default:
        return Icons.hourglass_top_outlined;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final String label;

  const _StatusChip({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Color _color() {
    switch (status) {
      case 'pending':
        return AppColors.statusPending;
      case 'preparing':
        return AppColors.statusPreparing;
      case 'ready':
        return AppColors.statusReady;
      case 'done':
        return AppColors.statusDone;
      default:
        return AppColors.statusPending;
    }
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  static const _steps = [
    ('pending', 'Recebido', Icons.check),
    ('preparing', 'Em Preparo', Icons.outdoor_grill),
    ('ready', 'Pronto', Icons.done),
    ('done', 'Entregue', Icons.done_all),
  ];

  int get _currentStep {
    switch (status) {
      case 'pending':
        return 0;
      case 'preparing':
        return 1;
      case 'ready':
        return 2;
      case 'done':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = i ~/ 2;
          final done = _currentStep > stepIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: done ? AppColors.brandYellow : AppColors.brandGray,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final done = _currentStep >= stepIndex;
        final (_, label, icon) = _steps[stepIndex];
        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done ? AppColors.brandYellow : AppColors.brandGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: done ? AppColors.brandBlack : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                color: done ? AppColors.brandBlack : AppColors.textMuted,
              ),
            ),
          ],
        );
      }),
    );
  }
}
