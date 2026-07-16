import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class SimulatorService {
  static Timer? _timer;
  static bool isSimulating = false;

  static void startSimulation() {
    if (isSimulating) return;
    isSimulating = true;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final Random random = Random();

      // Simulation de données réalistes
      double temp = 22 + random.nextDouble() * 4; // Entre 22 et 26°C
      double energy = 1.0 + random.nextDouble() * 0.5; // Entre 1 et 1.5 kWh
      int co2 = 400 + random.nextInt(200); // Entre 400 et 600 ppm
      double cpu = 10 + random.nextDouble() * 5;

      final data = {
        'temperature': double.parse(temp.toStringAsFixed(1)),
        'energy': double.parse(energy.toStringAsFixed(2)),
        'co2': co2,
        'cpu': double.parse(cpu.toStringAsFixed(1)),
        'humidity': 45 + random.nextInt(10),
        'last_update': FieldValue.serverTimestamp(),
      };

      // 1. Mettre à jour le document principal
      await FirebaseFirestore.instance
          .collection('telemetry')
          .doc('current')
          .update(data);

      // 2. Ajouter à l'historique pour les graphiques
      await FirebaseFirestore.instance
          .collection('telemetry')
          .doc('current')
          .collection('history')
          .add(data);

      print("🚀 Simulation : Données envoyées à Firebase");
    });
  }

  static void stopSimulation() {
    _timer?.cancel();
    isSimulating = false;
  }
}
