import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase/supabase_service.dart';

abstract class IAuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
  Session? get currentSession;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> resetPassword({required String email});
}

class SupabaseAuthRepository implements IAuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient? _client;

  @override
  Stream<AuthState> get authStateChanges {
    final client = _client;
    if (client == null) return const Stream.empty();
    return client.auth.onAuthStateChange;
  }

  @override
  User? get currentUser => _client?.auth.currentUser;

  @override
  Session? get currentSession => _client?.auth.currentSession;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not configured. Check your .env file.');
    }
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    final user = response.user;
    if (user != null) {
      try {
        await client.from('profiles').upsert({
          'id': user.id,
          'display_name': displayName,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {
        // Silently continue if table not yet created
      }
    }

    return response;
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not configured. Check your .env file.');
    }
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;
    await client.auth.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase is not configured. Check your .env file.');
    }
    await client.auth.resetPasswordForEmail(email);
  }
}

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
});
