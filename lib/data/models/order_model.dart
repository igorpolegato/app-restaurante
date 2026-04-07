class OrderItemModel {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final String? observation;

  const OrderItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.observation,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    final raw = json['price'];
    if (raw is num) {
      parsedPrice = raw.toDouble();
    } else if (raw is String) {
      parsedPrice = double.tryParse(raw) ?? 0.0;
    }

    return OrderItemModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: parsedPrice,
      quantity: json['quantity'] as int? ?? 1,
      observation: json['observation'] as String?,
    );
  }

  double get subtotal => price * quantity;
}

class OrderModel {
  final int id;
  final int customerId;
  String status;
  final List<OrderItemModel> items;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.items,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final orderItems = (json['items'] as List? ?? [])
        .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['id'] as int,
      customerId: json['id_customer'] as int,
      status: json['status'] as String? ?? 'pending',
      items: orderItems,
    );
  }

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'preparing':
        return 'Em Preparo';
      case 'ready':
        return 'Pronto';
      case 'done':
        return 'Entregue';
      default:
        return 'Pendente';
    }
  }

  String get nextStatus {
    switch (status) {
      case 'pending':
        return 'preparing';
      case 'preparing':
        return 'ready';
      case 'ready':
        return 'done';
      default:
        return status;
    }
  }

  String get nextStatusLabel {
    switch (status) {
      case 'pending':
        return 'Iniciar Preparo';
      case 'preparing':
        return 'Marcar Pronto';
      case 'ready':
        return 'Marcar Entregue';
      default:
        return '';
    }
  }

  bool get canAdvance => status != 'done';
}
