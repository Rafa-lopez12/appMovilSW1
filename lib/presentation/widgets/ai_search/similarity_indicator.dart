// lib/presentation/widgets/ai_search/similarity_indicator.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SimilarityIndicator extends StatelessWidget {
  final double similarity;
  final bool showPercentage;

  const SimilarityIndicator({
    Key? key,
    required this.similarity,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (similarity * 100).round();
    final Color color = _getColorBySimilarity(similarity);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: AppColors.border,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: similarity,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color,
              ),
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  Color _getColorBySimilarity(double similarity) {
    if (similarity >= 0.8) return AppColors.success;
    if (similarity >= 0.6) return AppColors.warning;
    return AppColors.info;
  }
}
