import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() {
    final repo = ref.watch(authRepositoryProvider);
    return repo.currentUser;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final res = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      return res.user;
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final res = await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            displayName: displayName,
          );
      return res.user;
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return null;
    });
  }

  Future<void> resetPassword({required String email}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).resetPassword(email: email);
      return state.value;
    });
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);
