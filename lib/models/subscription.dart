/// Les 3 paliers d'abonnement de DEM Smart Building Monitor.
enum SubscriptionTier { free, pro, enterprise }

extension SubscriptionTierX on SubscriptionTier {
  static SubscriptionTier fromString(String? value) {
    switch (value) {
      case 'pro':
        return SubscriptionTier.pro;
      case 'enterprise':
        return SubscriptionTier.enterprise;
      case 'free':
      default:
        return SubscriptionTier.free;
    }
  }

  String get id {
    switch (this) {
      case SubscriptionTier.free:
        return 'free';
      case SubscriptionTier.pro:
        return 'pro';
      case SubscriptionTier.enterprise:
        return 'enterprise';
    }
  }

  String get label {
    switch (this) {
      case SubscriptionTier.free:
        return 'Gratuit';
      case SubscriptionTier.pro:
        return 'Pro';
      case SubscriptionTier.enterprise:
        return 'Entreprise';
    }
  }

  /// Peut piloter les relais (Éclairage / HVAC).
  bool get canControlIot => this != SubscriptionTier.free;

  /// Nombre de points d'historique affichés dans Analytics.
  int get analyticsHistoryLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 10;
      case SubscriptionTier.pro:
        return 100;
      case SubscriptionTier.enterprise:
        return 500;
    }
  }

  /// Nombre de bâtiments gérables. -1 = illimité.
  /// NOTE : non appliqué techniquement pour l'instant, l'app ne gère
  /// qu'un seul bâtiment (voir lib/services/database_service.dart).
  int get maxBuildings {
    switch (this) {
      case SubscriptionTier.free:
        return 1;
      case SubscriptionTier.pro:
        return 5;
      case SubscriptionTier.enterprise:
        return -1;
    }
  }
}
