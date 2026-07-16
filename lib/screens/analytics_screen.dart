import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme.dart';
import '../models/telemetry.dart';
import '../models/subscription.dart';
import '../services/database_service.dart';

/// Onglet "Analytics" : historique température / CO₂ sous forme de courbes,
/// alimenté par la sous-collection Firestore `telemetry/current/history`.
/// La profondeur de l'historique dépend du palier d'abonnement.
class AnalyticsScreen extends StatelessWidget {
  final SubscriptionTier tier;

  const AnalyticsScreen({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Telemetry>>(
      stream: DatabaseService.instance
          .telemetryHistory(limit: tier.analyticsHistoryLimit),
      builder: (context, snapshot) {
        final List<Telemetry> raw = snapshot.data ?? [];
        // La requête est triée par date décroissante : on inverse pour tracer
        // la courbe dans l'ordre chronologique (gauche = plus ancien).
        final List<Telemetry> history = raw.reversed.toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ANALYTICS', style: AppTheme.displayFont(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                'Historique des relevés capteurs · Palier ${tier.label} '
                '(${tier.analyticsHistoryLimit} points max)',
                style: AppTheme.bodyFont(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              if (history.length < 2)
                _buildEmptyState()
              else ...[
                _buildChartCard(
                  title: 'TEMPÉRATURE (°C)',
                  icon: LucideIcons.thermometer,
                  color: AppColors.cyan,
                  spots: _spotsFrom(history, (t) => t.temperature),
                ),
                const SizedBox(height: 20),
                _buildChartCard(
                  title: 'CO₂ (ppm)',
                  icon: LucideIcons.wind,
                  color: AppColors.warning,
                  spots: _spotsFrom(history, (t) => t.co2),
                ),
                const SizedBox(height: 20),
                _buildChartCard(
                  title: 'ÉNERGIE (kWh)',
                  icon: LucideIcons.zap,
                  color: AppColors.success,
                  spots: _spotsFrom(history, (t) => t.energy),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<FlSpot> _spotsFrom(
      List<Telemetry> history, double Function(Telemetry) selector) {
    return List.generate(
      history.length,
      (i) => FlSpot(i.toDouble(), selector(history[i])),
    );
  }

  Widget _buildEmptyState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassDecoration(radius: 24),
          child: Column(
            children: [
              Icon(LucideIcons.barChart3,
                  color: AppColors.textSecondary, size: 32),
              const SizedBox(height: 12),
              Text(
                'Pas encore assez de données',
                style: AppTheme.bodyFont(
                    fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Les graphiques apparaissent dès que l\'ESP32 (ou l\'app) enregistre '
                'plusieurs relevés dans telemetry/current/history.',
                style: AppTheme.bodyFont(
                    fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<FlSpot> spots,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 20, 12),
          decoration: AppTheme.glassDecoration(radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(title,
                      style: AppTheme.monoFont(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: null,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.glassBorder,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: const FlTitlesData(
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 34),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: color,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withOpacity(0.12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
