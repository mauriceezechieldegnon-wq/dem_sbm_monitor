import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../main.dart'; // Pour rediriger vers l'AuthGate

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulation du temps de chargement des composants Firebase
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Effet de halo central
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha:0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icone de l'app (Placeholder en attendant ton image)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cyan.withValues(alpha:0.3)),
                  ),
                  child:
                      const Icon(Icons.bolt, color: AppColors.cyan, size: 50),
                ),
                const SizedBox(height: 20),
                Text(
                  "DEM SBM",
                  style:
                      AppTheme.displayFont(fontSize: 28, color: AppColors.cyan),
                ),
                Text(
                  "DEM Smart Building Monitor",
                  style: AppTheme.monoFont(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Branding en bas de page
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "by Maurice Ezéchiël",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "DEM Electrical Engineering",
                  style: GoogleFonts.shareTechMono(
                    color: AppColors.cyan.withValues(alpha:0.7),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Copyright © Aout 2026 · Tous droits réservés",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.3),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
