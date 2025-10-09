import 'package:flutter/foundation.dart';
import '../core/models/profile.dart';
import '../core/services/database_service.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  Profile? _profile;
  bool _isLoading = false;

  Profile? get profile => _profile;
  bool get hasProfile => _profile != null;
  bool get isLoading => _isLoading;

  /// Load profile data from database
  Future<void> loadProfile() async {
    _setLoading(true);
    try {
      _profile = await _db.getProfile();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading profile: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Create new profile (used on first onboarding)
  Future<void> createProfile(Profile profile) async {
    _setLoading(true);
    try {
      await _db.insertProfile(profile);
      _profile = profile;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating profile: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Update existing profile and refresh
  Future<void> updateProfile(Profile profile) async {
    _setLoading(true);
    try {
      await _db.updateProfile(profile);
      _profile = await _db.getProfile();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Internal helper to toggle loading safely
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
