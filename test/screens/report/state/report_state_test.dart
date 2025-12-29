import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'report_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  ReportRepository,
  UserState,
  Logger,
])
void main() {
  late MockReportRepository mockReportRepository;
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late ReportState reportState;

  setUp(() {
    mockReportRepository = MockReportRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    reportState = ReportState(
      mockReportRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(
      AppUser(
        uid: 'testUserId',
        displayName: 'Test User',
        searchName: 'test user',
        profilePictureURL: 'https://example.com/test.jpg',
      ),
    );
  });

  group('ReportState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(reportState.status, ReportStatus.initial);
        expect(reportState.error, isA<Error>());
        expect(reportState.contentId, isEmpty);
        expect(reportState.type, isEmpty);
        expect(reportState.comment, isEmpty);
      });
    });

    group('sendReport', () {
      test('should send report successfully', () async {
        // Arrange
        reportState.setContentId = 'content123';
        reportState.setType = 'spam';
        reportState.setComment = 'This is spam content';

        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        // Act
        await reportState.sendReport();

        // Assert
        expect(reportState.status, ReportStatus.loaded);
        verify(mockReportRepository.create(
          report: argThat(
            isA<Report>()
                .having((r) => r.contentId, 'contentId', 'content123')
                .having((r) => r.reporterId, 'reporterId', 'testUserId')
                .having((r) => r.comment, 'comment', 'This is spam content')
                .having((r) => r.type, 'type', 'spam'),
            named: 'report',
          ),
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle null currentUser gracefully', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        reportState.setContentId = 'content123';
        reportState.setType = 'spam';
        reportState.setComment = 'Test comment';

        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        // Act
        await reportState.sendReport();

        // Assert
        expect(reportState.status, ReportStatus.loaded);
        verify(mockReportRepository.create(
          report: argThat(
            isA<Report>().having((r) => r.reporterId, 'reporterId', ''),
            named: 'report',
          ),
        )).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        reportState.setContentId = 'content123';
        reportState.setType = 'inappropriate';
        reportState.setComment = 'Inappropriate content';

        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });

        // Act
        final future = reportState.sendReport();

        // Wait a tiny bit to ensure the status has been set
        await Future.delayed(Duration(milliseconds: 10));

        // Assert intermediate state
        expect(reportState.status, ReportStatus.loading);

        // Wait for completion
        await future;
        expect(reportState.status, ReportStatus.loaded);
      });

      test('should handle error during report submission', () async {
        // Arrange
        reportState.setContentId = 'content123';
        reportState.setType = 'spam';
        reportState.setComment = 'This is spam';

        when(mockReportRepository.create(report: anyNamed('report'))).thenThrow(Exception('Network error'));

        // Act
        await reportState.sendReport();

        // Assert
        expect(reportState.status, ReportStatus.error);
        expect(reportState.error.message, 'There was an issue reporting the content. Please try again');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle database error', () async {
        // Arrange
        reportState.setContentId = 'content456';
        reportState.setType = 'harassment';
        reportState.setComment = 'User is harassing others';

        when(mockReportRepository.create(report: anyNamed('report')))
            .thenThrow(Exception('Database connection failed'));

        // Act
        await reportState.sendReport();

        // Assert
        expect(reportState.status, ReportStatus.error);
        expect(reportState.error.message, 'There was an issue reporting the content. Please try again');
      });

      test('should create report with all fields populated', () async {
        // Arrange
        reportState.setContentId = 'post789';
        reportState.setType = 'violence';
        reportState.setComment = 'Contains violent content';

        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        // Act
        await reportState.sendReport();

        // Assert
        final captured = verify(mockReportRepository.create(
          report: captureAnyNamed('report'),
        )).captured.single as Report;

        expect(captured.contentId, 'post789');
        expect(captured.reporterId, 'testUserId');
        expect(captured.comment, 'Contains violent content');
        expect(captured.type, 'violence');
      });
    });

    group('Setters', () {
      test('setContentId should update contentId', () {
        reportState.setContentId = 'newContentId123';
        expect(reportState.contentId, 'newContentId123');
      });

      test('setContentId should handle empty string', () {
        reportState.setContentId = 'content123';
        reportState.setContentId = '';
        expect(reportState.contentId, isEmpty);
      });

      test('setComment should update comment', () {
        reportState.setComment = 'This is a test comment';
        expect(reportState.comment, 'This is a test comment');
      });

      test('setComment should handle empty string', () {
        reportState.setComment = 'Initial comment';
        reportState.setComment = '';
        expect(reportState.comment, isEmpty);
      });

      test('setComment should handle long comments', () {
        final longComment = 'A' * 500;
        reportState.setComment = longComment;
        expect(reportState.comment, longComment);
        expect(reportState.comment.length, 500);
      });

      test('setType should update type', () {
        reportState.setType = 'spam';
        expect(reportState.type, 'spam');
      });

      test('setType should handle different report types', () {
        final types = ['spam', 'harassment', 'violence', 'inappropriate', 'other'];

        for (final type in types) {
          reportState.setType = type;
          expect(reportState.type, type);
        }
      });

      test('setStatus should update status', () {
        reportState.setStatus = ReportStatus.loading;
        expect(reportState.status, ReportStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        reportState.setError = error;

        expect(reportState.status, ReportStatus.error);
        expect(reportState.error, error);
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in contentId', () {
        reportState.setContentId = 'content-123_abc@xyz';
        expect(reportState.contentId, 'content-123_abc@xyz');
      });

      test('should handle special characters in comment', () {
        reportState.setComment = 'Comment with special chars: !@#\$%^&*()';
        expect(reportState.comment, 'Comment with special chars: !@#\$%^&*()');
      });

      test('should handle unicode characters in comment', () {
        reportState.setComment = 'Unicode: 你好 🌟 émoji';
        expect(reportState.comment, 'Unicode: 你好 🌟 émoji');
      });

      test('should handle multiple sendReport calls in sequence', () async {
        // Arrange
        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        // First report
        reportState.setContentId = 'content1';
        reportState.setType = 'spam';
        reportState.setComment = 'First report';
        await reportState.sendReport();
        expect(reportState.status, ReportStatus.loaded);

        // Second report
        reportState.setContentId = 'content2';
        reportState.setType = 'harassment';
        reportState.setComment = 'Second report';
        await reportState.sendReport();

        // Assert
        expect(reportState.status, ReportStatus.loaded);
        verify(mockReportRepository.create(report: anyNamed('report'))).called(2);
      });

      test('should handle empty values when sending report', () async {
        // Arrange - all fields empty
        reportState.setContentId = '';
        reportState.setType = '';
        reportState.setComment = '';

        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        // Act
        await reportState.sendReport();

        // Assert - should still send report with empty values
        expect(reportState.status, ReportStatus.loaded);
        verify(mockReportRepository.create(
          report: argThat(
            isA<Report>()
                .having((r) => r.contentId, 'contentId', '')
                .having((r) => r.type, 'type', '')
                .having((r) => r.comment, 'comment', ''),
            named: 'report',
          ),
        )).called(1);
      });

      test('should maintain state after error', () async {
        // Arrange
        reportState.setContentId = 'content123';
        reportState.setType = 'spam';
        reportState.setComment = 'Spam content';

        when(mockReportRepository.create(report: anyNamed('report'))).thenThrow(Exception('Network error'));

        // Act
        await reportState.sendReport();

        // Assert - state values should be maintained after error
        expect(reportState.status, ReportStatus.error);
        expect(reportState.contentId, 'content123');
        expect(reportState.type, 'spam');
        expect(reportState.comment, 'Spam content');
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when sending report', () async {
        // Arrange
        reportState.setContentId = 'content123';
        reportState.setType = 'spam';
        reportState.setComment = 'Test comment';

        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        bool notified = false;
        reportState.addListener(() => notified = true);

        // Act
        await reportState.sendReport();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when error occurs', () async {
        // Arrange
        reportState.setContentId = 'content123';
        reportState.setType = 'spam';
        reportState.setComment = 'Test';

        when(mockReportRepository.create(report: anyNamed('report'))).thenThrow(Exception('Error'));

        bool notified = false;
        reportState.addListener(() => notified = true);

        // Act
        await reportState.sendReport();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting contentId', () {
        bool notified = false;
        reportState.addListener(() => notified = true);

        reportState.setContentId = 'newContent123';

        expect(notified, true);
      });

      test('should notify listeners when setting comment', () {
        bool notified = false;
        reportState.addListener(() => notified = true);

        reportState.setComment = 'New comment';

        expect(notified, true);
      });

      test('should notify listeners when setting type', () {
        bool notified = false;
        reportState.addListener(() => notified = true);

        reportState.setType = 'spam';

        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        reportState.addListener(() => notified = true);

        reportState.setStatus = ReportStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error is set', () {
        bool notified = false;
        reportState.addListener(() => notified = true);

        reportState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners multiple times during sendReport', () async {
        // Arrange
        reportState.setContentId = 'content123';
        reportState.setType = 'spam';
        reportState.setComment = 'Test';

        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        int notificationCount = 0;
        reportState.addListener(() => notificationCount++);

        // Act
        await reportState.sendReport();

        // Assert - should notify at least twice (loading and loaded)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });
    });

    group('Integration Tests', () {
      test('should complete full report submission flow', () async {
        // Arrange
        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        // Act - Set all required fields
        reportState.setContentId = 'post123';
        reportState.setType = 'inappropriate';
        reportState.setComment = 'This content is inappropriate';

        expect(reportState.status, ReportStatus.initial);

        // Submit report
        await reportState.sendReport();

        // Assert
        expect(reportState.status, ReportStatus.loaded);
        expect(reportState.contentId, 'post123');
        expect(reportState.type, 'inappropriate');
        expect(reportState.comment, 'This content is inappropriate');
      });

      test('should handle full error flow', () async {
        // Arrange
        when(mockReportRepository.create(report: anyNamed('report'))).thenThrow(Exception('Submission failed'));

        // Act - Set all required fields
        reportState.setContentId = 'post456';
        reportState.setType = 'spam';
        reportState.setComment = 'Spam content';

        // Submit report
        await reportState.sendReport();

        // Assert
        expect(reportState.status, ReportStatus.error);
        expect(reportState.error.message, 'There was an issue reporting the content. Please try again');
        // Values should remain unchanged
        expect(reportState.contentId, 'post456');
        expect(reportState.type, 'spam');
        expect(reportState.comment, 'Spam content');
      });

      test('should allow retry after error', () async {
        // Arrange - First attempt fails
        when(mockReportRepository.create(report: anyNamed('report'))).thenThrow(Exception('Network error'));

        reportState.setContentId = 'content789';
        reportState.setType = 'violence';
        reportState.setComment = 'Violent content';

        await reportState.sendReport();
        expect(reportState.status, ReportStatus.error);

        // Act - Second attempt succeeds
        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        await reportState.sendReport();

        // Assert
        expect(reportState.status, ReportStatus.loaded);
        verify(mockReportRepository.create(report: anyNamed('report'))).called(2);
      });

      test('should handle changing fields between submissions', () async {
        // Arrange
        when(mockReportRepository.create(report: anyNamed('report'))).thenAnswer((_) async => {});

        // First submission
        reportState.setContentId = 'content1';
        reportState.setType = 'spam';
        reportState.setComment = 'Spam';
        await reportState.sendReport();

        // Change fields
        reportState.setContentId = 'content2';
        reportState.setType = 'harassment';
        reportState.setComment = 'Harassment';

        // Second submission
        await reportState.sendReport();

        // Assert
        expect(reportState.status, ReportStatus.loaded);
        final captured = verify(mockReportRepository.create(
          report: captureAnyNamed('report'),
        )).captured;

        expect(captured.length, 2);
        final firstReport = captured[0] as Report;
        final secondReport = captured[1] as Report;

        expect(firstReport.contentId, 'content1');
        expect(firstReport.type, 'spam');
        expect(secondReport.contentId, 'content2');
        expect(secondReport.type, 'harassment');
      });
    });
  });
}
