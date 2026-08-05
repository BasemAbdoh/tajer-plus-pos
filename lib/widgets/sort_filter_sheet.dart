import 'package:flutter/material.dart';
import '../core/sort_options.dart';

class SortFilterSheet extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortSelected;

  const SortFilterSheet({
    Key? key,
    required this.currentSort,
    required this.onSortSelected,
  }) : super(key: key);

  IconData _getIconForOption(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return Icons.new_releases;
      case SortOption.oldest:
        return Icons.history;
      case SortOption.priceHigh:
        return Icons.arrow_upward;
      case SortOption.priceLow:
        return Icons.arrow_downward;
      case SortOption.profitHigh:
        return Icons.trending_up;
      case SortOption.profitLow:
        return Icons.trending_down;
      case SortOption.nameAZ:
        return Icons.sort_by_alpha;
      case SortOption.stockLow:
        return Icons.warning_amber;
      case SortOption.expirySoon:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'فرز وتصفية المنتجات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: SortOption.values.map((option) {
                  final isSelected = option == currentSort;
                  return ListTile(
                    leading: Icon(
                      _getIconForOption(option),
                      color: isSelected ? const Color.fromARGB(255, 42, 150, 177) : Colors.grey,
                    ),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color.fromARGB(255, 42, 150, 177) : null,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Color.fromARGB(255, 42, 150, 177)) : null,
                    onTap: () {
                      onSortSelected(option);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
