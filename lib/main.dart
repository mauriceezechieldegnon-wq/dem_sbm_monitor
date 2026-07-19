import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons_flutter.dart';

import 'firebase_options.dart';
import 'core/theme.dart';
import 'models/telemetry.dart';
import 'models/subscription.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'services/subscription_service.dart';
import 'services/team_service.dart';
import 'services/alarm_manager.dart'; // IMPORT ALARME
import 'services/simulator_service.dart'; // IMPORT SIMULATEUR

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/team_screen.dart';
import 'screens/access_denied_screen.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Erreur Firebase: $e");
  }
  runApp(const DemSbmApp());
}

class DemSbmApp extends StatelessWidget {
  const DemSbmApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEM SBM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();

        return FutureBuilder<bool>(
          future: TeamService.instance.checkUserAccess(user.email!),
          builder: (context, accessSnapshot) {
            if (accessSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            if (accessSnapshot.data == false) return const AccessDeniedScreen();

            _provisioning(user);
            return MissionControlScreen(uid: user.uid);
          },
        );
      },
    );
  }

  void _provisioning(User user) {
    SubscriptionService.instance
        .ensureUserDocument(uid: user.uid, email: user.email!);
    DatabaseService.instance.ensureDocumentExists();
    SimulatorService.startSimulation(); // On démarre le simulateur
  }
}

class MissionControlScreen extends StatefulWidget {
  final String uid;
  const MissionControlScreen({super.key, required this.uid});
  @override
  State<MissionControlScreen> createState() => _MissionControlScreenState();
}

class _MissionControlScreenState extends State<MissionControlScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: StreamBuilder<SubscriptionTier>(
        stream: SubscriptionService.instance.subscriptionStream(widget.uid),
        builder: (context, tierSnapshot) {
          final tier = tierSnapshot.data ?? SubscriptionTier.free;

          return StreamBuilder<Telemetry>(
            stream: DatabaseService.instance.telemetryStream(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? Telemetry.empty();
              final bool alertMode = data.smokeDetected || data.co2 > 1000;

              // --- LOGIQUE SONORE ---
              if (alertMode) {
                AlarmManager.instance.playEmergency();
              } else {
                AlarmManager.instance.stopAlarm();
              }

              final List<Widget> tabs = [
                DashboardScreen(
                    data: data,
                    connected: snapshot.hasData,
                    alertMode: alertMode,
                    tier: tier),
                AnalyticsScreen(tier: tier),
                AlertsScreen(current: data),
                const TeamScreen(),
                SettingsScreen(tier: tier),
              ];

              return Stack(
                children: [
                  _buildBackgroundGlows(alertMode),
                  SafeArea(
                    child: Column(
                      children: [
                        if (alertMode) _buildAlertBanner(),
                        Expanded(
                            child:
                                IndexedStack(index: _navIndex, children: tabs)),
                      ],
                    ),
                  ),
                  Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: _buildFloatingNav()),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBackgroundGlows(bool alertMode) {
    final Color glowColor = alertMode ? AppColors.dangerBright : AppColors.cyan;
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        color: AppColors.navy,
        child: Stack(
          children: [
            Positioned(
                top: -80,
                left: -60,
                child: _glow(glowColor.withValues(alpha:0.2), 260)),
            Positioned(
                top: 200,
                right: -100,
                child: _glow(AppColors.cyanDim.withValues(alpha:0.15), 240)),
            Positioned(
                bottom: -60,
                left: 40,
                child: _glow(glowColor.withValues(alpha:0.1), 220)),
          ],
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha:0)])),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: AppColors.dangerBright,
      child: Row(
        children: [
          Icon(LucideIcons.flame, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text('ALERTE CRITIQUE - ÉVACUATION',
                  style:
                      AppTheme.displayFont(fontSize: 14, color: Colors.white))),
          TextButton(
            onPressed: () => DatabaseService.instance.acknowledgeSmokeAlert(),
            child: Text('ACQUITTER',
                style: AppTheme.monoFont(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNav() {
    final items = [
      LucideIcons.layoutDashboard,
      LucideIcons.barChart3,
      LucideIcons.bell,
      LucideIcons.users,
      LucideIcons.settings
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha:0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.glassBorder)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final bool selected = index == _navIndex;
              return GestureDetector(
                onTap: () => setState(() => _navIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: selected
                          ? AppColors.cyan.withValues(alpha:0.15)
                          : Colors.transparent,
                      shape: BoxShape.circle),
                  child: Icon(items[index],
                      color:
                          selected ? AppColors.cyan : AppColors.textSecondary,
                      size: 22),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
