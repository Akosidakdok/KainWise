import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kainwise/features/auth/data/auth_repository.dart';
import 'package:kainwise/features/auth/presentation/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRepository implements IAuthRepository {
  User? _mockUser;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => _mockUser;

  @override
  Session? get currentSession => null;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _mockUser = User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {'display_name': displayName},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    return AuthResponse(session: null, user: _mockUser);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (password != 'correct_pass') {
      throw const AuthException('Invalid login credentials');
    }
    _mockUser = User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {'display_name': 'Test User'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    return AuthResponse(session: null, user: _mockUser);
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
  }

  @override
  Future<void> resetPassword({required String email}) async {}
}

void main() {
  group('AuthNotifier Tests', () {
    test('Initial user is null', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      final user = await container.read(authControllerProvider.future);
      expect(user, isNull);
    });

    test('Sign up sets current user', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).signUp(
            email: 'test@kainwise.app',
            password: 'password123',
            displayName: 'Juan Dela Cruz',
          );

      final state = container.read(authControllerProvider);
      expect(state.value?.email, 'test@kainwise.app');
      expect(state.value?.id, 'test-user-id');
    });

    test('Sign in with wrong password yields error', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).signIn(
            email: 'test@kainwise.app',
            password: 'wrong_password',
          );

      final state = container.read(authControllerProvider);
      expect(state.hasError, isTrue);
    });

    test('Sign out resets user to null', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).signUp(
            email: 'test@kainwise.app',
            password: 'password123',
            displayName: 'Juan Dela Cruz',
          );
      expect(container.read(authControllerProvider).value, isNotNull);

      await container.read(authControllerProvider.notifier).signOut();
      expect(container.read(authControllerProvider).value, isNull);
    });
  });
}
