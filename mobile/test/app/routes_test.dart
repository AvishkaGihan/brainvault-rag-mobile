import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainvault/app/routes.dart';

void main() {
  group('GoRouter Auth-Aware Navigation Tests', () {
    test('GoRouterRefreshStream notifies listeners on stream events', () async {
      // Arrange
      final controller = StreamController<int>();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      var listenerCalled = false;
      refreshStream.addListener(() {
        listenerCalled = true;
      });

      // Act
      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      expect(listenerCalled, isTrue);

      // Cleanup
      refreshStream.dispose();
      await controller.close();
    });

    test('GoRouterRefreshStream disposes subscription properly', () async {
      // Arrange
      final controller = StreamController<int>();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      // Act
      refreshStream.dispose();

      // Assert - No exception should be thrown
      expect(controller.hasListener, isFalse);

      // Cleanup
      await controller.close();
    });

    test('GoRouterRefreshStream handles multiple events', () async {
      // Arrange
      final controller = StreamController<int>();
      final refreshStream = GoRouterRefreshStream(controller.stream);

      var notificationCount = 0;
      refreshStream.addListener(() {
        notificationCount++;
      });

      // Act - Send multiple events
      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(2);
      await Future.delayed(const Duration(milliseconds: 10));
      controller.add(3);
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert - Should have been notified for each event
      expect(notificationCount, 3);

      // Cleanup
      refreshStream.dispose();
      await controller.close();
    });
  });
}
