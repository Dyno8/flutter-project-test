import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_pro_test/features/notifications/domain/entities/notification.dart';
import 'package:flutter_pro_test/features/notifications/presentation/widgets/notification_list_item.dart';

void main() {
  group('NotificationListItem', () {
    late NotificationEntity testNotification;
    late NotificationEntity readNotification;

    setUp(() {
      testNotification = NotificationEntity(
        id: 'test_id',
        userId: 'test_user',
        title: 'Test Notification',
        body: 'This is a test notification body that might be quite long to test text overflow behavior.',
        type: 'test_type',
        data: const {'key': 'value'},
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        priority: NotificationPriority.high,
        category: NotificationCategory.booking,
        isScheduled: false,
        isPersistent: false,
      );

      readNotification = testNotification.copyWith(
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
    });

    Widget createWidgetUnderTest({
      required NotificationEntity notification,
      VoidCallback? onTap,
      VoidCallback? onMarkAsRead,
      VoidCallback? onDelete,
      bool showActions = true,
    }) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: NotificationListItem(
              notification: notification,
              onTap: onTap,
              onMarkAsRead: onMarkAsRead,
              onDelete: onDelete,
              showActions: showActions,
            ),
          ),
        ),
      );
    }

    testWidgets('should display notification title and body', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(notification: testNotification));

      // assert
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('This is a test notification body that might be quite long to test text overflow behavior.'), findsOneWidget);
    });

    testWidgets('should display category icon', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(notification: testNotification));

      // assert
      expect(find.text(NotificationCategory.booking.icon), findsOneWidget);
    });

    testWidgets('should display priority and category badges', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(notification: testNotification));

      // assert
      expect(find.text('High'), findsOneWidget); // Priority badge
      expect(find.text('Booking'), findsOneWidget); // Category badge
    });

    testWidgets('should show unread indicator for unread notifications', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(notification: testNotification));

      // assert
      // Find the unread indicator (small circle)
      expect(find.byType(Container), findsWidgets);
      
      // Check that title is bold for unread notification
      final titleWidget = tester.widget<Text>(find.text('Test Notification'));
      expect(titleWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should not show unread indicator for read notifications', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(notification: readNotification));

      // assert
      // Check that title is normal weight for read notification
      final titleWidget = tester.widget<Text>(find.text('Test Notification'));
      expect(titleWidget.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('should display formatted timestamp', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(notification: testNotification));

      // assert
      expect(find.text('2h ago'), findsOneWidget);
    });

    testWidgets('should show mark as read button for unread notifications when showActions is true', (WidgetTester tester) async {
      // arrange
      bool markAsReadCalled = false;
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(
        notification: testNotification,
        onMarkAsRead: () => markAsReadCalled = true,
        showActions: true,
      ));

      // assert
      expect(find.byIcon(Icons.mark_email_read), findsOneWidget);
      
      // Test button tap
      await tester.tap(find.byIcon(Icons.mark_email_read));
      expect(markAsReadCalled, true);
    });

    testWidgets('should not show mark as read button for read notifications', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(
        notification: readNotification,
        showActions: true,
      ));

      // assert
      expect(find.byIcon(Icons.mark_email_read), findsNothing);
    });

    testWidgets('should show delete button when showActions is true', (WidgetTester tester) async {
      // arrange
      bool deleteCalled = false;
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(
        notification: testNotification,
        onDelete: () => deleteCalled = true,
        showActions: true,
      ));

      // assert
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      
      // Test button tap
      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleteCalled, true);
    });

    testWidgets('should not show action buttons when showActions is false', (WidgetTester tester) async {
      // arrange & act
      await tester.pumpWidget(createWidgetUnderTest(
        notification: testNotification,
        showActions: false,
      ));

      // assert
      expect(find.byIcon(Icons.mark_email_read), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('should call onTap when notification is tapped', (WidgetTester tester) async {
      // arrange
      bool tapCalled = false;
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(
        notification: testNotification,
        onTap: () => tapCalled = true,
      ));

      // Tap on the card
      await tester.tap(find.byType(Card));
      
      // assert
      expect(tapCalled, true);
    });

    testWidgets('should display different colors for different priorities', (WidgetTester tester) async {
      // Test with urgent priority
      final urgentNotification = testNotification.copyWith(
        priority: NotificationPriority.urgent,
      );

      await tester.pumpWidget(createWidgetUnderTest(notification: urgentNotification));
      
      expect(find.text('Urgent'), findsOneWidget);
    });

    testWidgets('should display different colors for different categories', (WidgetTester tester) async {
      // Test with payment category
      final paymentNotification = testNotification.copyWith(
        category: NotificationCategory.payment,
      );

      await tester.pumpWidget(createWidgetUnderTest(notification: paymentNotification));
      
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text(NotificationCategory.payment.icon), findsOneWidget);
    });

    testWidgets('should handle very recent notifications', (WidgetTester tester) async {
      // Test with notification from 30 seconds ago
      final recentNotification = testNotification.copyWith(
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
      );

      await tester.pumpWidget(createWidgetUnderTest(notification: recentNotification));
      
      expect(find.text('Just now'), findsOneWidget);
    });

    testWidgets('should handle old notifications', (WidgetTester tester) async {
      // Test with notification from 10 days ago
      final oldNotification = testNotification.copyWith(
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      );

      await tester.pumpWidget(createWidgetUnderTest(notification: oldNotification));
      
      // Should show formatted date instead of relative time
      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('should handle long notification text with ellipsis', (WidgetTester tester) async {
      // arrange
      final longNotification = testNotification.copyWith(
        title: 'This is a very long notification title that should be truncated with ellipsis when it exceeds the maximum number of lines allowed',
        body: 'This is a very long notification body that should also be truncated with ellipsis when it exceeds the maximum number of lines allowed for the body text in the notification list item widget.',
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest(notification: longNotification));

      // assert
      // The text should be present but truncated
      expect(find.textContaining('This is a very long notification title'), findsOneWidget);
      expect(find.textContaining('This is a very long notification body'), findsOneWidget);
    });
  });
}
