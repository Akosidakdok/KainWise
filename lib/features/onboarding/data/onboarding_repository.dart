import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase/supabase_service.dart';
import '../domain/user_goal_model.dart';
import '../domain/user_profile_model.dart';

abstract class IOnboardingRepository {
  Future<void> saveProfile(UserProfileModel profile);
  Future<UserProfileModel?> getProfile(String userId);
  Future<void> saveGoal(UserGoalModel goal);
  Future<UserGoalModel?> getGoal(String userId);
}

class SupabaseOnboardingRepository implements IOnboardingRepository {
  SupabaseOnboardingRepository(this._client);

  final SupabaseClient? _client;

  // Local cache fallback when developing without active DB
  static final Map<String, UserProfileModel> _localProfiles = {};
  static final Map<String, UserGoalModel> _localGoals = {};

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    _localProfiles[profile.id] = profile;
    final client = _client;
    if (client != null) {
      await client.from('profiles').upsert(profile.toJson());
    }
  }

  @override
  Future<UserProfileModel?> getProfile(String userId) async {
    final client = _client;
    if (client != null) {
      try {
        final data = await client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (data != null) {
          return UserProfileModel.fromJson(data);
        }
      } catch (_) {}
    }
    return _localProfiles[userId];
  }

  @override
  Future<void> saveGoal(UserGoalModel goal) async {
    _localGoals[goal.userId] = goal;
    final client = _client;
    if (client != null) {
      await client.from('user_goals').upsert(
            goal.toJson(),
            onConflict: 'user_id',
          );
    }
  }

  @override
  Future<UserGoalModel?> getGoal(String userId) async {
    final client = _client;
    if (client != null) {
      try {
        final data = await client
            .from('user_goals')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        if (data != null) {
          return UserGoalModel.fromJson(data);
        }
      } catch (_) {}
    }
    return _localGoals[userId];
  }
}

final onboardingRepositoryProvider = Provider<IOnboardingRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseOnboardingRepository(client);
});
