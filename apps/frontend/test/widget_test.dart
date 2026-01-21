// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:facility_erp/main.dart';
import 'package:facility_erp/src/features/auth/data/repositories/auth_repository.dart';
import 'package:facility_erp/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:facility_erp/src/core/di/service_locator.dart';

void main() {
  testWidgets('App widget can be instantiated', (WidgetTester tester) async {
    // Setup service locator for testing
    await setupServiceLocator();
    
    // Create Auth BLoC for testing
    final authBloc = AuthBloc(
      authRepository: getIt<AuthRepository>(),
    );

    // Build our app widget wrapped with BlocProvider
    // Note: This is a basic smoke test. For full integration tests,
    // you'll need to provide mock repositories and BLoCs.
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: FacilityErpApp(authBloc: authBloc),
      ),
    );

    // Verify that the widget builds without throwing
    expect(tester.takeException(), isNull);
  });
}
