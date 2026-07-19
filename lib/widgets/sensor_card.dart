import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Carte capteur réutilisable au style "vitré" (glassmorphism).
/// Passe automatiquement en mode alerte rouge si [isAlert] est vrai.
class SensorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool isAlert;
  final Color? accentColor;

  const SensorCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.isAlert = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent =
        isAlert ? AppColors.dangerBright : (accentColor ?? AppColors.cyan);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassDecoration(
            borderColor: isAlert
                ? AppColors.dangerBright.withValues(alpha:0.6)
                : AppColors.glassBorder,
            backgroundColor: isAlert
                ? AppColors.dangerBright.withValues(alpha:0.08)
                : AppColors.glass,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  if (isAlert)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.dangerBright,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                label.toUpperCase(),
                style: AppTheme.monoFont(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: AppTheme.displayFont(fontSize: 26, color: accent),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: AppTheme.bodyFont(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
