import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../shared/pantry_settings_sheet.dart';
import '../shared/pantry_store.dart';
import '../shared/shopping_list_store.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({super.key});

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ShoppingListStore.instance,
      builder: (context, child) {
        final store = ShoppingListStore.instance;
        final memos = store.memos;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '필요한 물건을 적어두시면 동네마트 특가 소식을 알려드려요.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '품목을 입력하세요...',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    store.addMemo(text);
                    _controller.clear();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              child: Column(
                children: memos.map((memo) {
                  final highlighted = memo.contains('계란');
                  return CheckboxListTile(
                    value: false,
                    onChanged: (_) {},
                    title: Text(memo),
                    subtitle: highlighted
                        ? Text(
                            '행복한식자재마트 단구점에서 ₩6,900 특가 진행 중',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                    secondary: IconButton(
                      tooltip: '삭제',
                      onPressed: () => store.removeMemo(memo),
                      icon: const Icon(Icons.close),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '집에 있는 품목 (기본 조미료)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                TextButton(
                  onPressed: () => showPantrySettingsSheet(context),
                  child: const Text('재료 설정'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '저장된 재료를 바탕으로 레시피를 추천해드립니다.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            AnimatedBuilder(
              animation: PantryStore.instance,
              builder: (context, child) {
                final store = PantryStore.instance;
                final selected = store.selected.toList()..sort();
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selected
                      .map(
                        (item) => FilterChip(
                          selected: true,
                          onSelected: (_) => store.toggle(item),
                          label: Text(item),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
