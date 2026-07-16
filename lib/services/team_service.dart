import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class TeamService {
  TeamService._internal();
  static final TeamService instance = TeamService._internal();

  // Voici la variable qui manquait (en minuscules avec underscore)
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection de référence
  CollectionReference get _teamCollection => _db.collection('team_members');

  /// Vérifie si l'utilisateur actuel a le droit d'entrer dans l'app
  Future<bool> checkUserAccess(String email) async {
    final doc = await _teamCollection.doc(email.toLowerCase()).get();
    if (!doc.exists) return false;
    return doc.get('is_active') == true;
  }

  /// Invite un nouveau membre
  Future<void> inviteMember(String email) async {
    // SÉCURITÉ : Si l'email est vide, on arrête tout avant de toucher à Firestore
    if (email.trim().isEmpty || !email.contains('@')) {
      debugPrint("Tentative d'invitation avec un email invalide.");
      return;
    }

    try {
      await _teamCollection.doc(email.trim().toLowerCase()).set({
        'email': email.trim().toLowerCase(),
        'role': 'operator',
        'is_active': true,
        'added_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Erreur lors de l'invitation : $e");
    }
  }

  /// Désactive ou Active un membre
  Future<void> toggleMemberStatus(String email, bool status) async {
    await _teamCollection.doc(email).update({'is_active': status});
  }

  /// Supprime un membre (révoque l'accès)
  Future<void> removeMember(String email) async {
    await _teamCollection.doc(email).delete();
  }

  /// Supprimer son propre compte (Firestore + Auth)
  Future<void> deleteSelfAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final email = user.email!.toLowerCase();
    await _teamCollection.doc(email).delete();
    await _db.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  /// Liste des membres en temps réel
  Stream<QuerySnapshot> get teamStream => _teamCollection.snapshots();
}
