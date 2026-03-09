import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/user_profile_repository.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
      return UserProfileNotifier();
    });

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final UserProfileRepository _repo = UserProfileRepository();

  UserProfileNotifier() : super(null) {
    _load();
  }

  void _load() {
    state = _repo.getProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repo.saveProfile(profile);
    state = profile;
  }
}
