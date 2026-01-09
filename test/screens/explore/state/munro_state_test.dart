import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/explore/state/munro_state.dart';

import 'munro_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  MunroRepository,
  Logger,
])
void main() {
  late MockMunroRepository mockMunroRepository;
  late MockLogger mockLogger;
  late MunroState munroState;

  // Sample munro data for testing
  final sampleMunros = [
    Munro(
      id: 1,
      name: 'Ben Nevis',
      extra: 'Highest peak',
      area: 'Fort William',
      meters: 1345,
      section: '04A',
      region: '04A: Fort William',
      feet: 4413,
      lat: 56.7969,
      lng: -5.0037,
      link: 'https://example.com/ben-nevis',
      description: 'The highest mountain in Scotland',
      pictureURL: 'https://example.com/ben-nevis.jpg',
      startingPointURL: 'https://maps.google.com',
      saved: false,
      averageRating: 4.5,
      reviewCount: 150,
    ),
    Munro(
      id: 2,
      name: 'Ben Macdui',
      extra: null,
      area: 'Cairngorms',
      meters: 1309,
      section: '08A',
      region: '08A: Cairngorms',
      feet: 4295,
      lat: 57.0700,
      lng: -3.6687,
      link: 'https://example.com/ben-macdui',
      description: 'Second highest mountain in Scotland',
      pictureURL: 'https://example.com/ben-macdui.jpg',
      startingPointURL: 'https://maps.google.com',
      saved: false,
      averageRating: 4.2,
      reviewCount: 85,
    ),
    Munro(
      id: 3,
      name: 'Ben Lomond',
      extra: 'Popular',
      area: 'Loch Lomond',
      meters: 974,
      section: '01C',
      region: '01C: Loch Lomond to Strathyre',
      feet: 3196,
      lat: 56.1903,
      lng: -4.6330,
      link: 'https://example.com/ben-lomond',
      description: 'Most popular munro near Glasgow',
      pictureURL: 'https://example.com/ben-lomond.jpg',
      startingPointURL: 'https://maps.google.com',
      saved: true,
      averageRating: 4.8,
      reviewCount: 200,
    ),
  ];

  setUp(() {
    mockMunroRepository = MockMunroRepository();
    mockLogger = MockLogger();
    munroState = MunroState(mockMunroRepository, mockLogger);
  });

  group('MunroState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(munroState.status, MunroStatus.initial);
        expect(munroState.error, isA<Error>());
        expect(munroState.munroList, isEmpty);
        expect(munroState.filteredMunroList, isEmpty);
        expect(munroState.selectedMunroId, isNull);
        expect(munroState.selectedMunro, isNull);
        expect(munroState.sortOrder, SortOrder.alphabetical);
        expect(munroState.latLngBounds, isNull);
        expect(munroState.filterOptions, isA<FilterOptions>());
        expect(munroState.isFilterOptionsSet, false);
        expect(munroState.createPostFilteredMunroList, isEmpty);
        expect(munroState.bulkMunroUpdateList, isEmpty);
      });
    });

    group('loadMunros', () {
      test('should load munros successfully and update status', () async {
        // Arrange
        when(mockMunroRepository.getMunroData()).thenAnswer((_) async => sampleMunros);

        // Act
        await munroState.loadMunros();

        // Assert
        expect(munroState.status, MunroStatus.loaded);
        expect(munroState.munroList, sampleMunros);
        expect(munroState.filteredMunroList, sampleMunros);
        verify(mockMunroRepository.getMunroData()).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockMunroRepository.getMunroData()).thenThrow(Exception('Network error'));

        // Act
        await munroState.loadMunros();

        // Assert
        expect(munroState.status, MunroStatus.error);
        expect(munroState.error.code, contains('Exception: Network error'));
        expect(munroState.error.message, 'There was an issue loading the munro data');
        verify(mockMunroRepository.getMunroData()).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockMunroRepository.getMunroData()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleMunros;
        });

        // Act
        final future = munroState.loadMunros();

        // Assert intermediate state
        expect(munroState.status, MunroStatus.loading);

        // Wait for completion
        await future;
        expect(munroState.status, MunroStatus.loaded);
      });
    });

    group('syncCompletedIds', () {
      setUp(() {
        munroState.setMunroList = sampleMunros;
      });

      test('should update completed ids and trigger filter', () {
        // Arrange
        final completedIds = {1, 3};

        // Act
        munroState.syncCompletedIds(completedIds);

        // Assert - The completed IDs are used in filtering logic
        // Since no filter options are set, all munros should still be visible
        expect(munroState.filteredMunroList, hasLength(3));
      });

      test('should not update if ids are the same', () {
        // Arrange
        final completedIds = {1, 2};
        munroState.syncCompletedIds(completedIds);
        final initialFilteredList = List.from(munroState.filteredMunroList);

        // Act - sync with same IDs
        munroState.syncCompletedIds(completedIds);

        // Assert - no change should occur
        expect(munroState.filteredMunroList, equals(initialFilteredList));
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        munroState.setStatus = MunroStatus.loading;
        expect(munroState.status, MunroStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        munroState.setError = error;

        expect(munroState.status, MunroStatus.error);
        expect(munroState.error, error);
      });

      test('setMunroList should update munro list and trigger filter', () {
        munroState.setMunroList = sampleMunros;

        expect(munroState.munroList, sampleMunros);
        expect(munroState.filteredMunroList, sampleMunros);
      });

      test('setSelectedMunro should update selected munro', () {
        munroState.setSelectedMunro = sampleMunros.first;
        expect(munroState.selectedMunro, sampleMunros.first);
      });

      test('setSelectedMunroId should update selected munro ID', () {
        munroState.setSelectedMunroId = 123;
        expect(munroState.selectedMunroId, 123);
      });

      test('setFilterString should update filter and trigger filtering', () {
        munroState.setMunroList = sampleMunros;

        munroState.setFilterString = 'Ben Nevis';

        expect(munroState.filteredMunroList, hasLength(1));
        expect(munroState.filteredMunroList.first.name, 'Ben Nevis');
      });

      test('setLatLngBounds should update bounds and trigger filtering', () {
        final bounds = LatLngBounds(
          southwest: LatLng(56.0, -5.5),
          northeast: LatLng(57.0, -3.0),
        );
        munroState.setMunroList = sampleMunros;

        munroState.setLatLngBounds = bounds;

        expect(munroState.latLngBounds, bounds);
        // All sample munros should be within these bounds
        expect(munroState.filteredMunroList, hasLength(2));
      });

      test('setSortOrder should update sort order and trigger filtering', () {
        munroState.setMunroList = sampleMunros;

        munroState.setSortOrder = SortOrder.height;

        expect(munroState.sortOrder, SortOrder.height);
        // Should be sorted by height (highest first)
        expect(munroState.filteredMunroList.first.name, 'Ben Nevis'); // 1345m
        expect(munroState.filteredMunroList.last.name, 'Ben Lomond'); // 974m
      });

      test('setFilterOptions should update filter options', () {
        final filterOptions = FilterOptions()
          ..areas = ['Fort William']
          ..completed = ['Yes'];

        munroState.setMunroList = sampleMunros;
        munroState.setFilterOptions = filterOptions;

        expect(munroState.filterOptions, filterOptions);
        expect(munroState.isFilterOptionsSet, true);
      });

      test('setGroupFilterMunroIds should update group filter', () {
        munroState.setMunroList = sampleMunros;

        munroState.setGroupFilterMunroIds = [1]; // Exclude Ben Nevis

        expect(munroState.filteredMunroList, hasLength(2));
        expect(munroState.filteredMunroList.any((m) => m.id == 1), false);
      });
    });

    group('Filtering', () {
      setUp(() {
        munroState.setMunroList = sampleMunros;
      });

      test('should filter by search string in name', () {
        munroState.setFilterString = 'nevis';

        expect(munroState.filteredMunroList, hasLength(1));
        expect(munroState.filteredMunroList.first.name, 'Ben Nevis');
      });

      test('should filter by search string in area', () {
        munroState.setFilterString = 'cairngorms';

        expect(munroState.filteredMunroList, hasLength(1));
        expect(munroState.filteredMunroList.first.name, 'Ben Macdui');
      });

      test('should filter by search string in extra field', () {
        munroState.setFilterString = 'popular';

        expect(munroState.filteredMunroList, hasLength(1));
        expect(munroState.filteredMunroList.first.name, 'Ben Lomond');
      });

      test('should filter by area in FilterOptions', () {
        final filterOptions = FilterOptions()..areas = ['Fort William'];
        munroState.setFilterOptions = filterOptions;

        expect(munroState.filteredMunroList, hasLength(1));
        expect(munroState.filteredMunroList.first.area, 'Fort William');
      });

      test('should filter by completed status when Yes is selected', () {
        final completedIds = {3}; // Ben Lomond is completed
        munroState.syncCompletedIds(completedIds);

        final filterOptions = FilterOptions()..completed = ['Yes'];
        munroState.setFilterOptions = filterOptions;

        expect(munroState.filteredMunroList, hasLength(1));
        expect(munroState.filteredMunroList.first.id, 3);
      });

      test('should filter by completed status when No is selected', () {
        final completedIds = {3}; // Ben Lomond is completed
        munroState.syncCompletedIds(completedIds);

        final filterOptions = FilterOptions()..completed = ['No'];
        munroState.setFilterOptions = filterOptions;

        expect(munroState.filteredMunroList, hasLength(2));
        expect(munroState.filteredMunroList.any((m) => m.id == 3), false);
      });

      test('should filter by lat/lng bounds', () {
        // Bounds that exclude Ben Lomond (most southern munro)
        final bounds = LatLngBounds(
          southwest: LatLng(56.5, -6.0),
          northeast: LatLng(58.0, -3.0),
        );
        munroState.setLatLngBounds = bounds;

        expect(munroState.filteredMunroList, hasLength(2));
        expect(munroState.filteredMunroList.any((m) => m.name == 'Ben Lomond'), false);
      });

      test('should apply multiple filters together', () {
        munroState.setFilterString = 'ben';
        final filterOptions = FilterOptions()..areas = ['Cairngorms'];
        munroState.setFilterOptions = filterOptions;

        expect(munroState.filteredMunroList, hasLength(1));
        expect(munroState.filteredMunroList.first.name, 'Ben Macdui');
      });
    });

    group('Sorting', () {
      setUp(() {
        munroState.setMunroList = sampleMunros;
      });

      test('should sort alphabetically by default', () {
        expect(munroState.filteredMunroList.first.name, 'Ben Lomond');
        expect(munroState.filteredMunroList.last.name, 'Ben Nevis');
      });

      test('should sort by height descending', () {
        munroState.setSortOrder = SortOrder.height;

        expect(munroState.filteredMunroList.first.name, 'Ben Nevis'); // 1345m
        expect(munroState.filteredMunroList[1].name, 'Ben Macdui'); // 1309m
        expect(munroState.filteredMunroList.last.name, 'Ben Lomond'); // 974m
      });

      test('should sort by rating descending', () {
        munroState.setSortOrder = SortOrder.rating;

        expect(munroState.filteredMunroList.first.name, 'Ben Lomond'); // 4.8
        expect(munroState.filteredMunroList[1].name, 'Ben Nevis'); // 4.5
        expect(munroState.filteredMunroList.last.name, 'Ben Macdui'); // 4.2
      });

      test('should sort by popularity (review count) descending', () {
        munroState.setSortOrder = SortOrder.popular;

        expect(munroState.filteredMunroList.first.name, 'Ben Lomond'); // 200 reviews
        expect(munroState.filteredMunroList[1].name, 'Ben Nevis'); // 150 reviews
        expect(munroState.filteredMunroList.last.name, 'Ben Macdui'); // 85 reviews
      });
    });

    group('Create Post Filtering', () {
      setUp(() {
        munroState.setMunroList = sampleMunros;
      });

      test('should filter create post list by name', () {
        munroState.setCreatePostFilterString = 'nevis';

        expect(munroState.createPostFilteredMunroList, hasLength(1));
        expect(munroState.createPostFilteredMunroList.first.name, 'Ben Nevis');
      });

      test('should filter create post list by area', () {
        munroState.setCreatePostFilterString = 'cairn';

        expect(munroState.createPostFilteredMunroList, hasLength(1));
        expect(munroState.createPostFilteredMunroList.first.name, 'Ben Macdui');
      });

      test('should return all munros when filter string is empty', () {
        munroState.setCreatePostFilterString = '';

        expect(munroState.createPostFilteredMunroList, hasLength(3));
      });
    });

    group('Bulk Munro Update Filtering', () {
      setUp(() {
        munroState.setMunroList = sampleMunros;
      });

      test('should filter bulk update list by name', () {
        munroState.setBulkMunroUpdateFilterString = 'macdui';

        expect(munroState.bulkMunroUpdateList, hasLength(1));
        expect(munroState.bulkMunroUpdateList.first.name, 'Ben Macdui');
      });

      test('should filter bulk update list by area', () {
        munroState.setBulkMunroUpdateFilterString = 'fort';

        expect(munroState.bulkMunroUpdateList, hasLength(1));
        expect(munroState.bulkMunroUpdateList.first.area, 'Fort William');
      });

      test('should return all munros when filter string is empty', () {
        munroState.setBulkMunroUpdateFilterString = '';

        expect(munroState.bulkMunroUpdateList, hasLength(3));
      });
    });

    group('clearFilterAndSorting', () {
      setUp(() {
        munroState.setMunroList = sampleMunros;
        // Set some filters and sorting
        munroState.setFilterString = 'test';
        munroState.setSortOrder = SortOrder.height;
        munroState.setLatLngBounds = LatLngBounds(
          southwest: LatLng(56.0, -5.5),
          northeast: LatLng(57.0, -3.0),
        );
        final filterOptions = FilterOptions()..areas = ['Fort William'];
        munroState.setFilterOptions = filterOptions;
      });

      test('should clear all filters and reset to default sorting', () {
        munroState.clearFilterAndSorting();

        expect(munroState.sortOrder, SortOrder.alphabetical);
        expect(munroState.latLngBounds, isNull);
        expect(munroState.filterOptions.areas, isEmpty);
        expect(munroState.filterOptions.completed, isEmpty);
        expect(munroState.isFilterOptionsSet, false);
        expect(munroState.filteredMunroList, hasLength(3));
      });
    });

    group('reset', () {
      setUp(() {
        munroState.setMunroList = sampleMunros;
        munroState.setSelectedMunro = sampleMunros.first;
        munroState.setFilterString = 'test';
        munroState.setCreatePostFilterString = 'test';
        munroState.setBulkMunroUpdateFilterString = 'test';
      });

      test('should reset all state to initial values', () {
        munroState.reset();

        expect(munroState.status, MunroStatus.initial);
        expect(munroState.error, isA<Error>());
        expect(munroState.munroList, isEmpty);
        expect(munroState.filteredMunroList, isEmpty);
        expect(munroState.createPostFilteredMunroList, isEmpty);
        expect(munroState.bulkMunroUpdateList, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle empty munro list', () {
        munroState.setMunroList = [];
        munroState.setFilterString = 'test';

        expect(munroState.filteredMunroList, isEmpty);
      });

      test('should handle null values in munro extra field during filtering', () {
        final munroWithNullExtra = Munro(
          id: 4,
          name: 'Test Munro',
          extra: null,
          area: 'Test Area',
          meters: 1000,
          section: 'TEST',
          region: 'Test Region',
          feet: 3280,
          lat: 56.0,
          lng: -4.0,
          link: 'https://example.com',
          description: 'Test description',
          pictureURL: 'https://example.com/pic.jpg',
          startingPointURL: 'https://maps.google.com',
          saved: false,
        );

        munroState.setMunroList = [munroWithNullExtra];
        munroState.setFilterString = 'nothing'; // Should not crash

        expect(munroState.filteredMunroList, isEmpty);
      });

      test('should handle munros with null rating and review count in sorting', () {
        final munroWithNulls = Munro(
          id: 5,
          name: 'No Reviews Munro',
          extra: null,
          area: 'Test Area',
          meters: 1200,
          section: 'TEST',
          region: 'Test Region',
          feet: 3937,
          lat: 56.5,
          lng: -4.5,
          link: 'https://example.com',
          description: 'Test description',
          pictureURL: 'https://example.com/pic.jpg',
          startingPointURL: 'https://maps.google.com',
          saved: false,
          averageRating: null,
          reviewCount: null,
        );

        munroState.setMunroList = [munroWithNulls, sampleMunros.first];

        // Test sorting by rating - should handle null values
        munroState.setSortOrder = SortOrder.rating;
        expect(munroState.filteredMunroList, hasLength(2));

        // Test sorting by popularity - should handle null values
        munroState.setSortOrder = SortOrder.popular;
        expect(munroState.filteredMunroList, hasLength(2));
      });

      test('should handle filter bounds that contain no munros', () {
        munroState.setMunroList = sampleMunros;

        // Set bounds that exclude all munros
        final bounds = LatLngBounds(
          southwest: LatLng(60.0, -10.0),
          northeast: LatLng(61.0, -9.0),
        );
        munroState.setLatLngBounds = bounds;

        expect(munroState.filteredMunroList, isEmpty);
      });

      test('should handle both completed filter options selected', () {
        munroState.setMunroList = sampleMunros;
        munroState.syncCompletedIds({1});

        final filterOptions = FilterOptions()..completed = ['Yes', 'No'];
        munroState.setFilterOptions = filterOptions;

        // When both are selected, should show all munros
        expect(munroState.filteredMunroList, hasLength(3));
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading munros', () async {
        when(mockMunroRepository.getMunroData()).thenAnswer((_) async => sampleMunros);

        bool notified = false;
        munroState.addListener(() => notified = true);

        await munroState.loadMunros();

        expect(notified, true);
      });

      test('should notify listeners when setting munro list', () {
        bool notified = false;
        munroState.addListener(() => notified = true);

        munroState.setMunroList = sampleMunros;

        expect(notified, true);
      });

      test('should notify listeners when filtering changes results', () {
        munroState.setMunroList = sampleMunros;

        bool notified = false;
        munroState.addListener(() => notified = true);

        munroState.setFilterString = 'nevis';

        expect(notified, true);
      });

      test('should not notify listeners when filtering produces same results', () {
        munroState.setMunroList = sampleMunros;

        // Apply filter that matches all munros
        munroState.setFilterString = 'ben';

        bool notified = false;
        munroState.addListener(() => notified = true);

        // Apply another filter that still matches all munros
        munroState.setFilterString = 'Ben';

        // Should not notify since filtered list is the same
        expect(notified, false);
      });
    });
  });
}
