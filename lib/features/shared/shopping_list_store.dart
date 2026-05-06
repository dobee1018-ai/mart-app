import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/shopping_memo_repository.dart';
import '../../models/shopping_memo.dart';
import 'mock_catalog.dart';

class ShoppingListStore extends ChangeNotifier {
  ShoppingListStore._();

  static final ShoppingListStore instance = ShoppingListStore._();

  final ShoppingMemoRepository _repository = ShoppingMemoRepository();
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
  final Map<String, String> _memoIds = {};
  final Map<String, String> _cartIds = {};

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<ShoppingMemo>>? _remoteSubscription;
  String? _userId;
  bool _applyingRemote = false;

  List<String> get memos => List.unmodifiable(_memos);

  List<ShoppingCartGroup> get cartGroups => _cartGroups;

  bool get isCloudSyncEnabled => _userId != null;

  void bindAuthState(Stream<User?> authStateChanges) {
    _authSubscription ??= authStateChanges.listen(_handleAuthChanged);
  }

  Future<void> _handleAuthChanged(User? user) async {
    await _remoteSubscription?.cancel();
    _remoteSubscription = null;
    _userId = user?.uid;
    _memoIds.clear();
    _cartIds.clear();

    if (user == null) {
      notifyListeners();
      return;
    }

    _remoteSubscription = _repository
        .watchMyMemos(user.uid)
        .listen(_replaceWithRemoteItems, onError: (_) {});
  }

  void _replaceWithRemoteItems(List<ShoppingMemo> remoteItems) {
    _applyingRemote = true;
    _memos
      ..clear()
      ..addAll(
        remoteItems
            .where((item) => item.kind == 'memo')
            .map((item) => item.productName),
      );
    _cartGroups.clear();
    _memoIds.clear();
    _cartIds.clear();

    for (final item in remoteItems) {
      if (item.kind == 'memo') {
        _memoIds[item.productName] = item.id;
        continue;
      }
      if (item.kind != 'cart') continue;
      final martName = item.martName;
      final price = item.price;
      if (martName == null || price == null) continue;
      _addCartLineLocally(
        martName: martName,
        name: item.productName,
        price: price,
        quantity: item.cartQuantity ?? 1,
      );
      _cartIds[_cartKey(martName, item.productName, price)] = item.id;
    }

    _applyingRemote = false;
    notifyListeners();
  }

  void addMemo(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    if (_memos.contains(value)) {
      _memos.remove(value);
    }
    _memos.insert(0, value);
    notifyListeners();
    _saveMemoToCloud(value);
  }

  void removeMemo(String text) {
    _memos.remove(text);
    notifyListeners();
    final id = _memoIds.remove(text);
    if (id != null) {
      _repository.deleteMemo(id);
    }
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
    final line = _addCartLineLocally(
      martName: martName,
      name: name,
      price: price,
    );
    notifyListeners();
    _saveCartLineToCloud(martName: martName, line: line);
  }

  ShoppingCartLine _addCartLineLocally({
    required String martName,
    required String name,
    required int price,
    int quantity = 1,
  }) {
    final group = _cartGroups
        .where((group) => group.martName == martName)
        .firstOrNull;
    if (group == null) {
      final line = ShoppingCartLine(name, price, quantity);
      _cartGroups.add(ShoppingCartGroup(martName: martName, items: [line]));
      return line;
    } else {
      final line = group.items.where((line) => line.name == name).firstOrNull;
      if (line == null) {
        final newLine = ShoppingCartLine(name, price, quantity);
        group.items.add(newLine);
        return newLine;
      } else {
        line.quantity += quantity;
        return line;
      }
    }
  }

  void removeCartGroup(String martName) {
    final group = _cartGroups
        .where((group) => group.martName == martName)
        .firstOrNull;
    if (group != null) {
      for (final line in List<ShoppingCartLine>.from(group.items)) {
        _deleteCartLineFromCloud(martName, line);
      }
    }
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
    _deleteCartLineFromCloud(martName, line);
  }

  void _saveMemoToCloud(String productName) {
    final userId = _userId;
    if (userId == null || _applyingRemote) return;
    final id = _memoIds[productName] ?? _repository.createId();
    _memoIds[productName] = id;
    _repository.setMemo(
      ShoppingMemo(
        id: id,
        userId: userId,
        productName: productName,
        createdAt: DateTime.now(),
      ),
    );
  }

  void _saveCartLineToCloud({
    required String martName,
    required ShoppingCartLine line,
  }) {
    final userId = _userId;
    if (userId == null || _applyingRemote) return;
    final key = _cartKey(martName, line.name, line.price);
    final id = _cartIds[key] ?? _repository.createId();
    _cartIds[key] = id;
    _repository.setMemo(
      ShoppingMemo(
        id: id,
        userId: userId,
        productName: line.name,
        createdAt: DateTime.now(),
        kind: 'cart',
        martName: martName,
        price: line.price,
        cartQuantity: line.quantity,
        alertEnabled: false,
      ),
    );
  }

  void _deleteCartLineFromCloud(String martName, ShoppingCartLine line) {
    if (_userId == null || _applyingRemote) return;
    final id = _cartIds.remove(_cartKey(martName, line.name, line.price));
    if (id != null) {
      _repository.deleteMemo(id);
    }
  }

  String _cartKey(String martName, String name, int price) {
    return '$martName|$name|$price';
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
