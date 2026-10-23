import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kainwise/app/app.dart';
import 'package:kainwise/core/constants/app_constants.dart';

void main() {
  testWidgets('App renders splash and navigates to login', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KainWiseApp(),
      ),
    );

    // Verify KainWise brand name is rendered on Splash screen
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text(AppConstants.appTagline), findsOneWidget);

    // Advance clock past splash timer (1200ms)
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify transition to Login screen
    expect(find.text('Welcome to ${AppConstants.appName}'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
