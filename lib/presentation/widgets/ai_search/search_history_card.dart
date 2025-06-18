// lib/presentation/widgets/ai_search/search_history_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/ai_search/clothing_analysis_model.dart';

class SearchHistoryCard extends StatefulWidget {
  final ClothingAnalysisModel analysis;
  final int resultCount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const SearchHistoryCard({
    Key? key,
    required this.analysis,
    required this.resultCount,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  State<SearchHistoryCard> createState() => _SearchHistoryCardState();
}

class _SearchHistoryCardState extends State<SearchHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          const SizedBox(height: 16),
          
          // Analysis summary
          _buildAnalysisSummary(),
          
          const SizedBox(height: 16),
          
          // Stats row
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Search icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            IconlyBold.search,
            color: Colors.white,
            size: 24,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Búsqueda Reciente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              Text(
                'Hace unos momentos',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // View results button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap?.call();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconlyLight.arrow_right,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
            
            if (widget.onDelete != null) ...[
              const SizedBox(width: 8),
              
              // Delete button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onDelete?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    IconlyLight.delete,
                    size: 16,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis Detectado',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Analysis chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Type chip
              if (widget.analysis.tipo.isNotEmpty)
                _buildAnalysisChip(
                  label: widget.analysis.tipo,
                  icon: IconlyLight.category,
                  color: AppColors.primary,
                ),
              
              // Primary color chip
              if (widget.analysis.colores.isNotEmpty)
                _buildAnalysisChip(
                  label: widget.analysis.primaryColor,
                  icon: IconlyLight.heart,
                  color: AppColors.secondary,
                ),
              
              // Style chip
              if (widget.analysis.estilo.isNotEmpty)
                _buildAnalysisChip(
                  label: widget.analysis.estilo,
                  icon: IconlyLight.star,
                  color: AppColors.accent,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Results count
        Expanded(
          child: _buildStatItem(
            icon: IconlyLight.image,
            label: 'Resultados',
            value: widget.resultCount.toString(),
            color: AppColors.success,
          ),
        ),
        
        Container(
          width: 1,
          height: 40,
          color: AppColors.divider,
        ),
        
        // Colors detected
        Expanded(
          child: _buildStatItem(
            icon: IconlyLight.heart,
            label: 'Colores',
            value: widget.analysis.colores.length.toString(),
            color: AppColors.info,
          ),
        ),
        
        Container(
          width: 1,
          height: 40,
          color: AppColors.divider,
        ),
        
        // Accuracy indicator
        Expanded(
          child: _buildStatItem(
            icon: IconlyLight.star,
            label: 'Precisión',
            value: '95%',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}