import 'package:flutter/foundation.dart';

import 'mock_catalog.dart';

class ShoppingListStore extends ChangeNotifier {
  ShoppingListStore._();

  static final ShoppingListStore instance = ShoppingListStore._();

  final List<String> _memos = ['우유 (1L)', '계란 (30구)', '양파'];
  final List<ShoppingCartGroup> _cartGroups = [
    ShoppingCartGroup(
      martName: '행복한식자재마트 단구점',
      items: [
        ShoppingCartLine('계란 30구', 6900, 1),
        ShoppingCartLine('맛있는 우유 900ml', 1980, 1),
      ],
    ),
    ShoppingCartGroup(
      martName: '상지식자재할인마트',
      items: [
        ShoppingCartLine('양파 15kg/망', 12000, 1),
        ShoppingCartLine('감자 3kg 박스', 6800, 1),
      ],
    ),
  ];

  List<String> get memos => List.unmodifiable(_memos);

  List<ShoppingCartGroup> get cartGroups => _cartGroups;

  void addMemo(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    if (_memos.contains(value)) {
      _memos.remove(value);
    }
    _memos.insert(0, value);
    notifyListeners();
  }

  void removeMemo(String text) {
    _memos.remove(text);
    notifyListeners();
  }

  void addDealToCart(DealItem item) {
    addCartLine(martName: item.martName, name: item.title, price: item.price);
  }

  void addComparisonToCart(MartPriceComparison comparison) {
    addCartLine(
      martName: comparison.martName,
      name: comparison.productName,
      price: comparison.price,
    );
  }

  void addCartLine({
    required String martName,
    required String name,
    required int price,
  }) {
    final group = _cartGroups
        .where((group) => group.martName == martName)
        .firstOrNull;
    if (group == null) {
      _cartGroups.add(
        ShoppingCartGroup(
          martName: martName,
          items: [ShoppingCartLine(name, price, 1)],
        ),
      );
    } else {
      final line = group.items.where((line) => line.name == name).firstOrNull;
      if (line == null) {
        group.items.add(ShoppingCartLine(name, price, 1));
      } else {
        line.quantity += 1;
      }
    }
    notifyListeners();
  }

  void removeCartGroup(String martName) {
    _cartGroups.removeWhere((group) => group.martName == martName);
    notifyListeners();
  }

  void removeCartLine(String martName, ShoppingCartLine line) {
    final group = _cartGroups
        .where((group) => group.martName == martName)
        .firstOrNull;
    if (group == null) return;
    group.items.remove(line);
    if (group.items.isEmpty) {
      _cartGroups.remove(group);
    }
    notifyListeners();
  }
}

class ShoppingCartGroup {
  ShoppingCartGroup({required this.martName, required this.items});

  final String martName;
  final List<ShoppingCartLine> items;

  int get total => items.fold(0, (sum, item) => sum + item.total);
}

class ShoppingCartLine {
  ShoppingCartLine(this.name, this.price, this.quantity);

  final String name;
  final int price;
  int quantity;

  int get total => price * quantity;
}
