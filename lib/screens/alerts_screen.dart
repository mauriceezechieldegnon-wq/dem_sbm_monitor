import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';

import '../core/theme.dart';
import '../models/telemetry.dart';
import '../services/database_service.dart';

/// Onglet "Alertes" : statut courant + historique des événements
/// (fumée détectée, CO₂ au-dessus du seuil) tirés de la sous-collection history.
class AlertsScreen extends StatelessWidget {
  final Telemetry current;

  const AlertsScreen({super.key, required this.current});

  static const double co2Threshold = 1000;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Telemetry>>(
      stream: DatabaseService.instance.telemetryHistory(limit: 50),
      builder: (context, snapshot) {
        final List<Telemetry> history = snapshot.data ?? [];
        final events = history
            .where((t) => t.smokeDetected || t.co2 > co2Threshold)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ALERTES', style: AppTheme.displayFont(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                'Statut du bâtiment en temps réel',
                style: AppTheme.bodyFont(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              _buildStatusCard(),
              const SizedBox(height: 24),
              Text('ÉVÉNEMENTS RÉCENTS',
                  style: AppTheme.monoFont(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              if (events.isEmpty)
                _buildEmptyState()
              else
                ...events.map(_buildEventTile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard() {
    final bool alert = current.smokeDetected || current.co2 > co2Threshold;
    final Color color = alert ? AppColors.dangerBright : AppColors.success;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration(
            radius: 24,
            borderColor: color.withOpacity(0.4),
            backgroundColor: color.withOpacity(0.08),
          ),
          child: Row(
            children: [
              Icon(alert ? LucideIcons.alertTriangle : LucideIcons.shieldCheck,
                  color: color, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert ? 'Anomalie en cours' : 'Tout est normal',
                      style: AppTheme.displayFont(fontSize: 16, color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      current.smokeDetected
                          ? 'Fumée détectée'
                          : current.co2 > co2Threshold
                              ? 'CO₂ élevé : ${current.co2.toStringAsFixed(0)} ppm'
                              : 'Aucun capteur en alerte actuellement',
                      style: AppTheme.bodyFont(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration(radius: 20),
          child: Text(
            'Aucun événement enregistré pour le moment.',
            style:
                AppTheme.bodyFont(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildEventTile(Telemetry event) {
    final bool isSmoke = event.smokeDetected;
    final Color color = isSmoke ? AppColors.dangerBright : AppColors.warning;
    final String label = isSmoke
        ? 'Fumée détectée'
        : 'CO₂ élevé (${event.co2.toStringAsFixed(0)} ppm)';
    final String timeLabel = event.lastUpdate != null
        ? '${event.lastUpdate!.hour.toString().padLeft(2, '0')}:${event.lastUpdate!.minute.toString().padLeft(2, '0')}'
        : '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: AppTheme.glassDecoration(radius: 16),
            child: Row(
              children: [
                Icon(isSmoke ? LucideIcons.flame : LucideIcons.wind,
                    color: color, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: AppTheme.bodyFont(fontSize: 13)),
                ),
                Text(timeLabel,
                    style: AppTheme.monoFont(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
