import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'pantry_store.dart';

Future<void> showPantrySettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _PantrySettingsSheet(),
  );
}

class _PantrySettingsSheet extends StatefulWidget {
  const _PantrySettingsSheet();

  @override
  State<_PantrySettingsSheet> createState() => _PantrySettingsSheetState();
}

class _PantrySettingsSheetState extends State<_PantrySettingsSheet> {
  final _controller = TextEditingController();
  final _store = PantryStore.instance;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '우리집 냉장고 재료 설정',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  '여기서 선택한 재료는 레시피 추천과 메모 페이지에 함께 반영됩니다.',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '재료 직접 추가',
                          filled: true,
                          fillColor: AppColors.background,
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
                        _store.add(_controller.text);
                        _controller.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      {
                        ...PantryStore.availableIngredients,
                        ..._store.selected,
                      }.map((ingredient) {
                        return FilterChip(
                          selected: _store.contains(ingredient),
                          onSelected: (_) => _store.toggle(ingredient),
                          label: Text(ingredient),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('설정 완료'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
