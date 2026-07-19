import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';

import '../core/theme.dart';
import '../models/telemetry.dart';
import '../models/subscription.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/sensor_card.dart';

/// Onglet "Dashboard" de la nav flottante : header, carte énergie,
/// grille de capteurs et contrôles IoT (Éclairage / HVAC).
class DashboardScreen extends StatefulWidget {
  final Telemetry data;
  final bool connected;
  final bool alertMode;
  final SubscriptionTier tier;

  const DashboardScreen({
    super.key,
    required this.data,
    required this.connected,
    required this.alertMode,
    required this.tier,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _liveBlinkController;

  @override
  void initState() {
    super.initState();
    _liveBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _liveBlinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildEnergyCard(data),
          const SizedBox(height: 24),
          Text('CAPTEURS',
              style: AppTheme.monoFont(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _buildSensorGrid(data),
          const SizedBox(height: 24),
          Text('CONTRÔLES',
              style: AppTheme.monoFont(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          if (!widget.tier.canControlIot) _buildUpgradeBanner(),
          if (!widget.tier.canControlIot) const SizedBox(height: 12),
          _buildControls(data),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('DEM SBM', style: AppTheme.displayFont(fontSize: 26)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => AuthService.instance.signOut(),
                  child: Icon(LucideIcons.logOut,
                      color: AppColors.textSecondary, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Smart Building Monitor',
              style: AppTheme.bodyFont(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        FadeTransition(
          opacity:
              Tween<double>(begin: 0.4, end: 1.0).animate(_liveBlinkController),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (widget.alertMode
                      ? AppColors.dangerBright
                      : AppColors.success)
                  .withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: (widget.alertMode
                        ? AppColors.dangerBright
                        : AppColors.success)
                    .withValues(alpha:0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.alertMode
                        ? AppColors.dangerBright
                        : AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.connected ? 'LIVE DATA' : 'CONNEXION...',
                  style: AppTheme.monoFont(
                    fontSize: 11,
                    color: widget.alertMode
                        ? AppColors.dangerBright
                        : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyCard(Telemetry data) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration(radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CONSOMMATION ÉNERGIE',
                      style: AppTheme.monoFont(
                          fontSize: 12, color: AppColors.textSecondary)),
                  Icon(LucideIcons.zap, color: AppColors.cyan, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(data.energy.toStringAsFixed(1),
                      style: AppTheme.displayFont(
                          fontSize: 42, color: AppColors.cyan)),
                  const SizedBox(width: 6),
                  Text('kWh',
                      style: AppTheme.bodyFont(
                          fontSize: 16, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (data.cpu / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Charge contrôleur (CPU) : ${data.cpu.toStringAsFixed(0)}%',
                style: AppTheme.bodyFont(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorGrid(Telemetry data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.25,
      children: [
        SensorCard(
          icon: LucideIcons.thermometer,
          label: 'Température',
          value: data.temperature.toStringAsFixed(1),
          unit: '°C',
        ),
        SensorCard(
          icon: LucideIcons.droplets,
          label: 'Humidité',
          value: data.humidity.toStringAsFixed(0),
          unit: '%',
        ),
        SensorCard(
          icon: LucideIcons.wind,
          label: 'CO₂',
          value: data.co2.toStringAsFixed(0),
          unit: 'ppm',
          isAlert: data.co2 > 1000,
        ),
        SensorCard(
          icon: LucideIcons.flame,
          label: 'Fumée',
          value: data.smokeDetected ? 'DÉTECTÉE' : 'NORMAL',
          unit: '',
          isAlert: data.smokeDetected,
        ),
      ],
    );
  }

  Widget _buildUpgradeBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppTheme.glassDecoration(
            radius: 16,
            borderColor: AppColors.warning.withValues(alpha:0.4),
            backgroundColor: AppColors.warning.withValues(alpha:0.08),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.lock, color: AppColors.warning, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pilotage verrouillé — passe au palier Pro pour activer Éclairage/HVAC.',
                  style:
                      AppTheme.bodyFont(fontSize: 12, color: AppColors.warning),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(Telemetry data) {
    final bool locked = !widget.tier.canControlIot;
    return Row(
      children: [
        Expanded(
          child: _controlTile(
            icon: LucideIcons.lightbulb,
            label: 'Éclairage',
            active: data.lightsOn,
            locked: locked,
            onChanged:
                locked ? null : (v) => DatabaseService.instance.toggleLights(v),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _controlTile(
            icon: LucideIcons.fan,
            label: 'HVAC',
            active: data.hvacOn,
            locked: locked,
            onChanged:
                locked ? null : (v) => DatabaseService.instance.toggleHvac(v),
          ),
        ),
      ],
    );
  }

  Widget _controlTile({
    required IconData icon,
    required String label,
    required bool active,
    required bool locked,
    required ValueChanged<bool>? onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: AppTheme.glassDecoration(
            radius: 18,
            borderColor: active && !locked
                ? AppColors.cyan.withValues(alpha:0.5)
                : AppColors.glassBorder,
            backgroundColor: active && !locked
                ? AppColors.cyan.withValues(alpha:0.08)
                : AppColors.glass,
          ),
          child: Row(
            children: [
              Icon(
                locked ? LucideIcons.lock : icon,
                color: active && !locked
                    ? AppColors.cyan
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(label, style: AppTheme.bodyFont(fontSize: 13))),
              Switch(
                value: active,
                onChanged: onChanged,
                activeThumbColor: AppColors.cyan,
                inactiveTrackColor: AppColors.surfaceLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
