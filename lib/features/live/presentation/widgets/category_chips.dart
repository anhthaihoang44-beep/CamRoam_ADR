import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
  });

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'all':
        return Icons.auto_awesome_rounded;
      case 'skyline':
        return Icons.location_city_rounded;
      case 'beach':
        return Icons.beach_access_rounded;
      case 'traffic':
        return Icons.traffic_rounded;
      case 'nature':
        return Icons.forest_rounded;
      case 'historic':
        return Icons.museum_rounded;
      case 'mountain':
        return Icons.terrain_rounded;
      default:
        return Icons.videocam_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat.toLowerCase() == selectedCategory.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              avatar: Icon(
                _getCategoryIcon(cat),
                size: 16,
                color: isSelected ? Colors.black : AppColors.cyan,
              ),
              label: Text(
                cat,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelect(cat),
              selectedColor: AppColors.cyan,
              backgroundColor: AppColors.surfaceCard,
              side: BorderSide(
                color: isSelected ? AppColors.cyan : AppColors.borderSubtle,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }
}

