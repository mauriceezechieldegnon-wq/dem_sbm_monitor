import 'package:firebase_auth/firebase_auth.dart';

/// Centralise l'authentification Firebase pour DEM Smart Building Monitor.
/// Un seul rôle "opérateur" pour l'instant (email/mot de passe).
class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Flux temps réel de l'état de connexion (null = déconnecté).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Connexion avec un compte existant.
  /// Lève une [FirebaseAuthException] en cas d'échec (gérée dans l'UI).
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  /// Création d'un nouveau compte opérateur.
  Future<void> signUp({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Traduit les codes d'erreur Firebase en messages lisibles en français.
  static String readableError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Adresse e-mail invalide.';
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'user-not-found':
          return 'Aucun compte ne correspond à cet e-mail.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou mot de passe incorrect.';
        case 'email-already-in-use':
          return 'Un compte existe déjà avec cet e-mail.';
        case 'weak-password':
          return 'Mot de passe trop faible (6 caractères minimum).';
        case 'too-many-requests':
          return 'Trop de tentatives. Réessaie dans quelques instants.';
        default:
          return 'Erreur d\'authentification : ${error.code}';
      }
    }
    return 'Une erreur inattendue est survenue.';
  }
}
