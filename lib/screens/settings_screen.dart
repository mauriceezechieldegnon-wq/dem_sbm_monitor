import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme.dart';
import '../models/subscription.dart';
import '../services/auth_service.dart';

/// Onglet "Réglages" : compte connecté, abonnement, infos projet Firebase, déconnexion.
class SettingsScreen extends StatelessWidget {
  final SubscriptionTier tier;

  const SettingsScreen({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final projectId = Firebase.app().options.projectId;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RÉGLAGES', style: AppTheme.displayFont(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            'Compte et informations du projet',
            style:
                AppTheme.bodyFont(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _buildSubscriptionCard(),
          const SizedBox(height: 14),
          _buildInfoCard(
            icon: LucideIcons.user,
            title: 'Compte opérateur',
            value: user?.email ?? 'Non connecté',
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            icon: LucideIcons.database,
            title: 'Projet Firebase',
            value: projectId,
          ),
          const SizedBox(height: 14),
          _buildInfoCard(
            icon: LucideIcons.cpu,
            title: 'Document temps réel',
            value: 'telemetry/current',
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => AuthService.instance.signOut(),
              icon: const Icon(LucideIcons.logOut,
                  size: 18, color: AppColors.danger),
              label: Text(
                'SE DÉCONNECTER',
                style: AppTheme.monoFont(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.danger.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final Color tierColor = switch (tier) {
      SubscriptionTier.free => AppColors.textSecondary,
      SubscriptionTier.pro => AppColors.cyan,
      SubscriptionTier.enterprise => AppColors.success,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassDecoration(
            radius: 18,
            borderColor: tierColor.withOpacity(0.4),
            backgroundColor: tierColor.withOpacity(0.06),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tierColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.crown, color: tierColor, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ABONNEMENT',
                            style: AppTheme.monoFont(
                                fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text('Palier ${tier.label}',
                            style: AppTheme.displayFont(
                                fontSize: 15, color: tierColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _entitlementRow(
                icon: tier.canControlIot
                    ? LucideIcons.checkCircle2
                    : LucideIcons.xCircle,
                text: 'Pilotage Éclairage / HVAC',
                enabled: tier.canControlIot,
              ),
              const SizedBox(height: 6),
              _entitlementRow(
                icon: LucideIcons.barChart3,
                text:
                    'Historique Analytics : ${tier.analyticsHistoryLimit} points',
                enabled: true,
              ),
              const SizedBox(height: 6),
              _entitlementRow(
                icon: LucideIcons.building,
                text: tier.maxBuildings == -1
                    ? 'Bâtiments : illimité'
                    : 'Bâtiments : ${tier.maxBuildings}',
                enabled: true,
              ),
              if (tier == SubscriptionTier.free) ...[
                const SizedBox(height: 12),
                Text(
                  'Pour changer de palier, contacte l\'administrateur (mise à jour '
                  'manuelle du champ subscription_tier dans Firestore).',
                  style: AppTheme.bodyFont(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _entitlementRow(
      {required IconData icon, required String text, required bool enabled}) {
    return Row(
      children: [
        Icon(icon,
            size: 14,
            color: enabled ? AppColors.success : AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: AppTheme.bodyFont(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      {required IconData icon, required String title, required String value}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassDecoration(radius: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.cyan, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTheme.monoFont(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(value, style: AppTheme.bodyFont(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
