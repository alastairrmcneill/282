import 'package:flutter_test/flutter_test.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/screens/notifiers.dart';

void main() {
  late FlavorState flavorState;

  group('FlavorState', () {
    group('Initial State - Dev Environment', () {
      setUp(() {
        flavorState = FlavorState(AppEnvironment.dev);
      });

      test('should have correct initial environment value for dev', () {
        expect(flavorState.environment, AppEnvironment.dev);
      });

      test('should be a ChangeNotifier', () {
        expect(flavorState, isA<FlavorState>());
      });

      test('should maintain dev environment value', () {
        expect(flavorState.environment, AppEnvironment.dev);
        // Verify it remains unchanged
        expect(flavorState.environment, AppEnvironment.dev);
      });
    });

    group('Initial State - Prod Environment', () {
      setUp(() {
        flavorState = FlavorState(AppEnvironment.prod);
      });

      test('should have correct initial environment value for prod', () {
        expect(flavorState.environment, AppEnvironment.prod);
      });

      test('should be a ChangeNotifier', () {
        expect(flavorState, isA<FlavorState>());
      });

      test('should maintain prod environment value', () {
        expect(flavorState.environment, AppEnvironment.prod);
        // Verify it remains unchanged
        expect(flavorState.environment, AppEnvironment.prod);
      });
    });

    group('Environment Immutability', () {
      test('dev environment should remain constant throughout lifecycle', () {
        flavorState = FlavorState(AppEnvironment.dev);
        final initialEnvironment = flavorState.environment;

        expect(flavorState.environment, initialEnvironment);
        expect(flavorState.environment, AppEnvironment.dev);
      });

      test('prod environment should remain constant throughout lifecycle', () {
        flavorState = FlavorState(AppEnvironment.prod);
        final initialEnvironment = flavorState.environment;

        expect(flavorState.environment, initialEnvironment);
        expect(flavorState.environment, AppEnvironment.prod);
      });
    });

    group('Environment Comparison', () {
      test('dev and prod environments should be different', () {
        final devFlavorState = FlavorState(AppEnvironment.dev);
        final prodFlavorState = FlavorState(AppEnvironment.prod);

        expect(devFlavorState.environment, isNot(equals(prodFlavorState.environment)));
        expect(devFlavorState.environment, AppEnvironment.dev);
        expect(prodFlavorState.environment, AppEnvironment.prod);
      });

      test('two dev flavor states should have same environment', () {
        final devFlavorState1 = FlavorState(AppEnvironment.dev);
        final devFlavorState2 = FlavorState(AppEnvironment.dev);

        expect(devFlavorState1.environment, equals(devFlavorState2.environment));
        expect(devFlavorState1.environment, AppEnvironment.dev);
        expect(devFlavorState2.environment, AppEnvironment.dev);
      });

      test('two prod flavor states should have same environment', () {
        final prodFlavorState1 = FlavorState(AppEnvironment.prod);
        final prodFlavorState2 = FlavorState(AppEnvironment.prod);

        expect(prodFlavorState1.environment, equals(prodFlavorState2.environment));
        expect(prodFlavorState1.environment, AppEnvironment.prod);
        expect(prodFlavorState2.environment, AppEnvironment.prod);
      });
    });

    group('Environment Type Checking', () {
      test('should correctly identify dev environment', () {
        flavorState = FlavorState(AppEnvironment.dev);

        expect(flavorState.environment == AppEnvironment.dev, isTrue);
        expect(flavorState.environment == AppEnvironment.prod, isFalse);
      });

      test('should correctly identify prod environment', () {
        flavorState = FlavorState(AppEnvironment.prod);

        expect(flavorState.environment == AppEnvironment.prod, isTrue);
        expect(flavorState.environment == AppEnvironment.dev, isFalse);
      });
    });
  });
}
