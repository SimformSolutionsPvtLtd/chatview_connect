import 'package:flutter/material.dart';

import '../../../models/chat_list_theme.dart';
import '../../../values/enums.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.value,
    required this.groupValue,
    required this.theme,
    this.onSelected,
    this.counts,
    super.key,
  });

  final int? counts;
  final VoidCallback? onSelected;
  final FilterType value;
  final FilterType groupValue;
  final ChatListTheme theme;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final count = counts ?? 0;
    final title = groupValue.label;
    return FilterChip.elevated(
      elevation: 0,
      pressElevation: 0,
      selected: isSelected,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 10,
      ),
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        color: isSelected ? theme.selectedChip : theme.chipText,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      backgroundColor: theme.chipBg,
      selectedColor: theme.selectedChipBg,
      label: Text(
        count > 0 ? '$title ($counts)' : title,
      ),
      onSelected: (_) => onSelected?.call(),
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
