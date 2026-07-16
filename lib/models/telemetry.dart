import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle représentant l'état complet du bâtiment (DEM Smart Building Monitor).
/// Correspond au document Firestore : telemetry/current
class Telemetry {
  final double temperature; // °C
  final double humidity; // %
  final double co2; // ppm
  final bool smokeDetected; // Détecteur de fumée
  final double energy; // kWh (consommation instantanée)
  final double cpu; // % charge CPU de l'ESP32 / contrôleur
  final bool lightsOn; // État relais éclairage
  final bool hvacOn; // État relais climatisation / ventilation
  final DateTime? lastUpdate;

  const Telemetry({
    required this.temperature,
    required this.humidity,
    required this.co2,
    required this.smokeDetected,
    required this.energy,
    required this.cpu,
    required this.lightsOn,
    required this.hvacOn,
    this.lastUpdate,
  });

  /// Valeurs par défaut affichées avant la première réponse de Firestore.
  factory Telemetry.empty() {
    return const Telemetry(
      temperature: 0,
      humidity: 0,
      co2: 0,
      smokeDetected: false,
      energy: 0,
      cpu: 0,
      lightsOn: false,
      hvacOn: false,
      lastUpdate: null,
    );
  }

  factory Telemetry.fromMap(Map<String, dynamic> map) {
    return Telemetry(
      temperature: _toDouble(map['temperature']),
      humidity: _toDouble(map['humidity']),
      co2: _toDouble(map['co2']),
      smokeDetected: map['smoke_detected'] as bool? ?? false,
      energy: _toDouble(map['energy']),
      cpu: _toDouble(map['cpu']),
      lightsOn: map['lights_on'] as bool? ?? false,
      hvacOn: map['hvac_on'] as bool? ?? false,
      lastUpdate: map['last_update'] is Timestamp
          ? (map['last_update'] as Timestamp).toDate()
          : null,
    );
  }

  factory Telemetry.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists || snap.data() == null) return Telemetry.empty();
    return Telemetry.fromMap(snap.data()!);
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'co2': co2,
      'smoke_detected': smokeDetected,
      'energy': energy,
      'cpu': cpu,
      'lights_on': lightsOn,
      'hvac_on': hvacOn,
      'last_update': FieldValue.serverTimestamp(),
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
