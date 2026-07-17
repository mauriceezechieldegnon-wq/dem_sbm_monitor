import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';

class AccessDeniedScreen extends StatelessWidget {
  final String message;
  const AccessDeniedScreen({super.key, this.message = "ACCÈS REFUSÉ"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Halo rouge d'alerte
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
                child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.15),
                        shape: BoxShape.circle),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                        child: Container()))),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.shieldAlert,
                      color: AppColors.danger, size: 80),
                  const SizedBox(height: 30),
                  Text(message,
                      style: AppTheme.displayFont(
                          fontSize: 22, color: AppColors.danger)),
                  const SizedBox(height: 15),
                  Text(
                    "Votre compte n'est pas autorisé à accéder à ce bâtiment ou a été désactivé par l'administrateur.",
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyFont(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight),
                      onPressed: () => AuthService.instance.signOut(),
                      child: Text("SE DÉCONNECTER",
                          style: AppTheme.monoFont(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
