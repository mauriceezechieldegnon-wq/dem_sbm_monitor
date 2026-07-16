import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/telemetry.dart';

/// Centralise tous les accès Firestore pour DEM Smart Building Monitor.
///
/// Collection utilisée : `telemetry`
/// Document temps réel  : `telemetry/current`
/// (Ce document est écrit en continu par l'ESP32 et lu en Stream par l'app,
/// et les champs `lights_on` / `hvac_on` sont écrits par l'app puis lus par
/// l'ESP32 pour piloter les relais physiques.)
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _currentDoc =>
      _db.collection('telemetry').doc('current');

  /// Flux temps réel de l'état du bâtiment.
  /// Utilisé avec StreamBuilder dans main.dart pour un rafraîchissement instantané.
  Stream<Telemetry> telemetryStream() {
    return _currentDoc.snapshots().map(Telemetry.fromSnapshot);
  }

  /// Historique des relevés (utilisé pour d'éventuels graphiques fl_chart).
  Stream<List<Telemetry>> telemetryHistory({int limit = 30}) {
    return _db
        .collection('telemetry')
        .doc('current')
        .collection('history')
        .orderBy('last_update', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Telemetry.fromMap(d.data())).toList());
  }

  /// Initialise le document `telemetry/current` s'il n'existe pas encore
  /// (utile lors du tout premier lancement de l'application / du provisioning).
  Future<void> ensureDocumentExists() async {
    final snap = await _currentDoc.get();
    if (!snap.exists) {
      await _currentDoc.set(Telemetry.empty().toMap());
    }
  }

  /// Bascule l'état du relais Éclairage. Le champ est repris par l'ESP32.
  Future<void> toggleLights(bool value) async {
    await _currentDoc.set(
      {
        'lights_on': value,
        'last_command': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Bascule l'état du relais HVAC (climatisation / ventilation).
  Future<void> toggleHvac(bool value) async {
    await _currentDoc.set(
      {
        'hvac_on': value,
        'last_command': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Acquitte manuellement une alerte fumée (reset logique côté app ;
  /// le capteur physique doit lui aussi repasser à l'état normal côté ESP32).
  Future<void> acknowledgeSmokeAlert() async {
    await _currentDoc.set(
      {
        'smoke_detected': false,
        'last_command': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
