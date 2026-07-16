import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';

/// Gère le document `users/{uid}` qui porte le champ `subscription_tier`.
///
/// Le statut est géré manuellement pour l'instant (via la Console Firebase
/// ou le SDK Admin) — aucun paiement réel n'est encore branché. Le client
/// ne peut QUE lire son propre abonnement, jamais le modifier lui-même
/// (voir les règles Firestore recommandées).
class SubscriptionService {
  SubscriptionService._internal();
  static final SubscriptionService instance = SubscriptionService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Crée le document utilisateur avec le palier "free" par défaut
  /// s'il n'existe pas encore. À appeler juste après signIn/signUp.
  Future<void> ensureUserDocument({required String uid, required String email}) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) {
      await _userDoc(uid).set({
        'email': email,
        'subscription_tier': SubscriptionTier.free.id,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Flux temps réel du palier d'abonnement de l'utilisateur connecté.
  /// Retombe sur "free" si le document ou le champ n'existe pas encore.
  Stream<SubscriptionTier> subscriptionStream(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      return SubscriptionTierX.fromString(data?['subscription_tier'] as String?);
    });
  }
}
