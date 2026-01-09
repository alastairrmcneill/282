import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_eight_two/screens/notifiers.dart';

void main() {
  late LayoutState layoutState;

  setUp(() {
    layoutState = LayoutState();
  });

  group('LayoutState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(layoutState.bottomNavBarHeight, 0);
      });
    });

    group('setBottomNavBarHeight', () {
      test('should update bottomNavBarHeight successfully', () {
        // Arrange
        const newHeight = 56.0;

        // Act
        layoutState.setBottomNavBarHeight = newHeight;

        // Assert
        expect(layoutState.bottomNavBarHeight, newHeight);
      });

      test('should update bottomNavBarHeight to zero', () {
        // Arrange
        layoutState.setBottomNavBarHeight = 100.0;
        const newHeight = 0.0;

        // Act
        layoutState.setBottomNavBarHeight = newHeight;

        // Assert
        expect(layoutState.bottomNavBarHeight, newHeight);
      });

      test('should update bottomNavBarHeight to negative value', () {
        // Arrange
        const newHeight = -10.0;

        // Act
        layoutState.setBottomNavBarHeight = newHeight;

        // Assert
        expect(layoutState.bottomNavBarHeight, newHeight);
      });

      test('should update bottomNavBarHeight to large value', () {
        // Arrange
        const newHeight = 1000.0;

        // Act
        layoutState.setBottomNavBarHeight = newHeight;

        // Assert
        expect(layoutState.bottomNavBarHeight, newHeight);
      });

      test('should update bottomNavBarHeight multiple times', () {
        // First update
        layoutState.setBottomNavBarHeight = 50.0;
        expect(layoutState.bottomNavBarHeight, 50.0);

        // Second update
        layoutState.setBottomNavBarHeight = 75.0;
        expect(layoutState.bottomNavBarHeight, 75.0);

        // Third update
        layoutState.setBottomNavBarHeight = 100.0;
        expect(layoutState.bottomNavBarHeight, 100.0);
      });

      test('should notify listeners when bottomNavBarHeight changes', () {
        // Arrange
        var listenerCallCount = 0;
        layoutState.addListener(() {
          listenerCallCount++;
        });

        // Act
        layoutState.setBottomNavBarHeight = 56.0;

        // Assert
        expect(listenerCallCount, 1);
      });

      test('should notify listeners on each update', () {
        // Arrange
        var listenerCallCount = 0;
        layoutState.addListener(() {
          listenerCallCount++;
        });

        // Act
        layoutState.setBottomNavBarHeight = 50.0;
        layoutState.setBottomNavBarHeight = 60.0;
        layoutState.setBottomNavBarHeight = 70.0;

        // Assert
        expect(listenerCallCount, 3);
      });

      test('should notify listeners even when setting same value', () {
        // Arrange
        layoutState.setBottomNavBarHeight = 56.0;
        var listenerCallCount = 0;
        layoutState.addListener(() {
          listenerCallCount++;
        });

        // Act
        layoutState.setBottomNavBarHeight = 56.0;

        // Assert
        expect(listenerCallCount, 1);
      });
    });

    group('Listener Management', () {
      test('should allow adding multiple listeners', () {
        // Arrange
        var listener1CallCount = 0;
        var listener2CallCount = 0;

        void listener1() {
          listener1CallCount++;
        }

        void listener2() {
          listener2CallCount++;
        }

        layoutState.addListener(listener1);
        layoutState.addListener(listener2);

        // Act
        layoutState.setBottomNavBarHeight = 56.0;

        // Assert
        expect(listener1CallCount, 1);
        expect(listener2CallCount, 1);
      });

      test('should allow removing listeners', () {
        // Arrange
        var listenerCallCount = 0;

        void listener() {
          listenerCallCount++;
        }

        layoutState.addListener(listener);
        layoutState.setBottomNavBarHeight = 50.0;
        expect(listenerCallCount, 1);

        // Act
        layoutState.removeListener(listener);
        layoutState.setBottomNavBarHeight = 60.0;

        // Assert
        expect(listenerCallCount, 1); // Should not have increased
      });

      test('should not notify removed listeners', () {
        // Arrange
        var listener1CallCount = 0;
        var listener2CallCount = 0;

        void listener1() {
          listener1CallCount++;
        }

        void listener2() {
          listener2CallCount++;
        }

        layoutState.addListener(listener1);
        layoutState.addListener(listener2);
        layoutState.removeListener(listener1);

        // Act
        layoutState.setBottomNavBarHeight = 56.0;

        // Assert
        expect(listener1CallCount, 0); // Removed listener not called
        expect(listener2CallCount, 1); // Active listener called
      });
    });

    group('Disposal', () {
      test('should be able to dispose the state', () {
        // Act & Assert - should not throw
        expect(() => layoutState.dispose(), returnsNormally);
      });

      test('should not notify listeners after disposal', () {
        // Act
        layoutState.dispose();

        // Assert - should throw when trying to update after disposal
        expect(
          () => layoutState.setBottomNavBarHeight = 56.0,
          throwsA(isA<FlutterError>()),
        );
      });
    });
  });
}
