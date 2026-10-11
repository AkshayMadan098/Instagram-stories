import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ColorPaletteBar extends StatelessWidget {
  final Color activeColor;
  final double strokeWidth;
  final bool isEraserActive;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onStrokeWidthChanged;
  final VoidCallback onToggleEraser;
  final VoidCallback onClearAll;

  const ColorPaletteBar({
    super.key,
    required this.activeColor,
    required this.strokeWidth,
    required this.isEraserActive,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onToggleEraser,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stroke width controls & utility buttons
          Row(
            children: [
              // Stroke width quick buttons
              _buildStrokeSizeButton(3.0, 'Fine'),
              const SizedBox(width: 8),
              _buildStrokeSizeButton(7.0, 'Medium'),
              const SizedBox(width: 8),
              _buildStrokeSizeButton(14.0, 'Bold'),

              const Spacer(),

              // Eraser toggle
              IconButton(
                icon: Icon(
                  Icons.auto_fix_high,
                  color: isEraserActive ? AppColors.accent : Colors.white70,
                ),
                tooltip: 'Eraser',
                onPressed: onToggleEraser,
              ),

              // Clear all strokes
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white70),
                tooltip: 'Clear Drawings',
                onPressed: onClearAll,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Horizontal Color dots
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppColors.paletteColors.length,
              itemBuilder: (context, index) {
                final color = AppColors.paletteColors[index];
                final isSelected = !isEraserActive && color == activeColor;

                return GestureDetector(
                  onTap: () => onColorChanged(color),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: isSelected ? 3.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokeSizeButton(double size, String label) {
    final isSelected = strokeWidth == size && !isEraserActive;
    return InkWell(
      onTap: () => onStrokeWidthChanged(size),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white30,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size > 10 ? 10 : size,
              height: size > 10 ? 10 : size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
