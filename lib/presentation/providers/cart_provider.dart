import 'package:flutter/material.dart';
import '../../data/models/item_model.dart';

class CartItem {
  final ItemModel item;
  int quantity;
  String? observation;

  CartItem({required this.item, this.quantity = 1, this.observation});

  double get subtotal => item.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, ci) => sum + ci.quantity);
  bool get isEmpty => _items.isEmpty;
  double get total => _items.values.fold(0.0, (sum, ci) => sum + ci.subtotal);

  bool hasItem(int itemId) => _items.containsKey(itemId);
  int quantityOf(int itemId) => _items[itemId]?.quantity ?? 0;

  void addItem(ItemModel item, {int quantity = 1, String? observation}) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity += quantity;
    } else {
      _items[item.id] =
          CartItem(item: item, quantity: quantity, observation: observation);
    }
    notifyListeners();
  }

  void removeItem(int itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  void increment(int itemId) {
    if (_items.containsKey(itemId)) {
      _items[itemId]!.quantity++;
      notifyListeners();
    }
  }

  void decrement(int itemId) {
    if (!_items.containsKey(itemId)) return;
    if (_items[itemId]!.quantity <= 1) {
      _items.remove(itemId);
    } else {
      _items[itemId]!.quantity--;
    }
    notifyListeners();
  }

  void setObservation(int itemId, String observation) {
    if (_items.containsKey(itemId)) {
      _items[itemId]!.observation = observation.isEmpty ? null : observation;
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderPayload() {
    return _items.values
        .map((ci) => {'id': ci.item.id, 'quantity': ci.quantity})
        .toList();
  }
}
