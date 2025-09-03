import 'package:flutter/material.dart';

import '../values/app_colors.dart';
import '../values/enums.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.value,
    required this.groupValue,
    this.onSelected,
    this.counts,
    super.key,
  });

  final int? counts;
  final VoidCallback? onSelected;
  final FilterType value;
  final FilterType groupValue;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return FilterChip.elevated(
      elevation: 0,
      pressElevation: 0,
      selected: isSelected,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 10,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      color: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.red200
            : AppColors.grey200,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.grey.shade600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      backgroundColor: Colors.grey.shade200,
      label: Text(
        counts == null ? groupValue.label : '${groupValue.label} ($counts)',
      ),
      onSelected: (_) => onSelected?.call(),
    );
  }
}
