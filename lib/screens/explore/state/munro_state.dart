import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/models/models.dart';

class MunroState extends ChangeNotifier {
  MunroStatus _status = MunroStatus.initial;
  Error _error = Error();
  List<Munro> _munroList = [];
  String? _selectedMunroId;
  Munro? _selectedMunro;
  List<Munro> _filteredMunroList = [];
  String _filterString = '';
  LatLngBounds? _latLngBounds;
  SortOrder _sortOrder = SortOrder.alphabetical;
  FilterOptions _filterOptions = FilterOptions();
  bool _isFilterOptionsSet = false;
  List<Munro> _createPostFilteredMunroList = [];
  String _createPostFilterString = '';
  List<Munro> _bulkMunroUpdateList = [];
  String _bulkMunroUpdateFilterString = '';
  List<String> _groupFilterMunroIds = [];

  MunroStatus get status => _status;
  Error get error => _error;
  List<Munro> get munroList => _munroList;
  List<Munro> get filteredMunroList => _filteredMunroList;
  SortOrder get sortOrder => _sortOrder;
  LatLngBounds? get latLngBounds => _latLngBounds;
  FilterOptions get filterOptions => _filterOptions;
  bool get isFilterOptionsSet => _isFilterOptionsSet;
  String? get selectedMunroId => _selectedMunroId;
  Munro? get selectedMunro => _selectedMunro;
  List<Munro> get createPostFilteredMunroList => _createPostFilteredMunroList;
  List<Munro> get bulkMunroUpdateList => _bulkMunroUpdateList;

  set setStatus(MunroStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = MunroStatus.error;
    _error = error;
    notifyListeners();
  }

  set setMunroList(List<Munro> munroList) {
    _munroList = munroList;
    _filter();
    notifyListeners();
  }

  set setSelectedMunro(Munro? selectedMunro) {
    _selectedMunro = selectedMunro;
    notifyListeners();
  }

  set setSelectedMunroId(String? selectedMunroId) {
    _selectedMunroId = selectedMunroId;
    notifyListeners();
  }

  updateMunro({
    required String munroId,
    bool? summited,
    DateTime? summitedDate,
    bool? saved,
  }) {
    int munroIndex = _munroList.indexWhere((munro) => munro.id == munroId);
    if (munroIndex == -1) return;
    _munroList[munroIndex].summited = summited ?? _munroList[munroIndex].summited;
    _munroList[munroIndex].summitedDate = summitedDate ?? _munroList[munroIndex].summitedDate;
    _munroList[munroIndex].saved = saved ?? _munroList[munroIndex].saved;

    if (summitedDate != null) {
      if (_munroList[munroIndex].summitedDates == null) {
        _munroList[munroIndex].summitedDates = [summitedDate];
      }
      _munroList[munroIndex].summitedDates!.add(summitedDate);
    }

    notifyListeners();
  }

  void removeMunroCompletion({
    required String munroId,
    required DateTime dateTime,
  }) {
    int munroIndex = _munroList.indexWhere((munro) => munro.id == munroId);
    if (munroIndex == -1) return;
    _munroList[munroIndex].summitedDates!.remove(dateTime);
    _munroList[munroIndex].summited = _munroList[munroIndex].summitedDates!.isNotEmpty;
    notifyListeners();
  }

  set setFilterString(String filterString) {
    _filterString = filterString;
    _filter();
  }

  set setLatLngBounds(LatLngBounds bounds) {
    _latLngBounds = bounds;
    _filter();
  }

  set setSortOrder(SortOrder sortOrder) {
    _sortOrder = sortOrder;
    _filter();
  }

  set setFilterOptions(FilterOptions filterOptions) {
    _filterOptions = filterOptions;
    _isFilterOptionsSet = _filterOptions.areas.isNotEmpty || _filterOptions.completed.isNotEmpty;

    _filter();
  }

  set setGroupFilterMunroIds(List<String> groupFilterMunroIds) {
    _groupFilterMunroIds = groupFilterMunroIds;
    _filter();
  }

  _filter() {
    // Start with all munros
    List<Munro> runningList = _munroList;
    List<Munro> initialList = _filteredMunroList;

    // Filter out lat/long bounds
    runningList = _filterLatLong(runningList);

    // Filter out search string
    runningList = _filterSearchString(runningList);

    // Filter out filters
    runningList = _filterOutFilterOptions(runningList);

    // Filter out group filter
    runningList = _filterOutGroupFilter(runningList);

    // Sort order
    runningList = _sort(runningList);

    _filteredMunroList = runningList;

    bool equal = _munroListsEqual(initialList, _filteredMunroList);

    if (!equal) {
      notifyListeners();
    }
  }

  void clearFilterAndSorting() {
    _filterString = '';
    _latLngBounds = null;
    _sortOrder = SortOrder.alphabetical;
    _filterOptions = FilterOptions();
    _isFilterOptionsSet = false;
    _filter();
  }

  set setCreatePostFilterString(String filterString) {
    _createPostFilterString = filterString;
    _createPostFilter();
  }

  _createPostFilter() {
    List<Munro> runningList = _munroList;
    if (_createPostFilterString != "") {
      runningList = _munroList.where(
        (munro) {
          if (munro.name.toLowerCase().contains(_createPostFilterString.toLowerCase())) return true;
          if (munro.area.toLowerCase().contains(_createPostFilterString.toLowerCase())) return true;
          if (munro.extra != null) {
            if (munro.extra!.toLowerCase().contains(_createPostFilterString.toLowerCase())) return true;
          }
          return false;
        },
      ).toList();
    }
    _createPostFilteredMunroList = runningList;
    notifyListeners();
  }

  set setBulkMunroUpdateFilterString(String filterString) {
    _bulkMunroUpdateFilterString = filterString;
    _bulkMunroUpdateFilter();
  }

  _bulkMunroUpdateFilter() {
    List<Munro> runningList = _munroList;
    if (_bulkMunroUpdateFilterString != "") {
      runningList = _munroList.where(
        (munro) {
          if (munro.name.toLowerCase().contains(_bulkMunroUpdateFilterString.toLowerCase())) return true;
          if (munro.area.toLowerCase().contains(_bulkMunroUpdateFilterString.toLowerCase())) return true;
          if (munro.extra != null) {
            if (munro.extra!.toLowerCase().contains(_bulkMunroUpdateFilterString.toLowerCase())) return true;
          }
          return false;
        },
      ).toList();
    }
    _bulkMunroUpdateList = runningList;
    notifyListeners();
  }

  reset() {
    _status = MunroStatus.initial;
    _error = Error();
    _munroList = [];
    _selectedMunro;
    _filteredMunroList = [];
    _filterString = '';
    _createPostFilteredMunroList = [];
    _createPostFilterString = '';
    _bulkMunroUpdateList = [];
    _bulkMunroUpdateFilterString = '';
    _filter();
    _createPostFilter();
    _bulkMunroUpdateFilter();
  }

  List<Munro> _filterLatLong(List<Munro> runningList) {
    if (_latLngBounds != null) {
      runningList = runningList.where((munro) {
        return _latLngBounds!.contains(LatLng(munro.lat, munro.lng));
      }).toList();
    }
    return runningList;
  }

  List<Munro> _filterSearchString(List<Munro> runningList) {
    if (_filterString != "") {
      runningList = runningList.where(
        (munro) {
          if (munro.name.toLowerCase().contains(_filterString.toLowerCase())) return true;
          if (munro.area.toLowerCase().contains(_filterString.toLowerCase())) return true;
          if (munro.extra != null) {
            if (munro.extra!.toLowerCase().contains(_filterString.toLowerCase())) return true;
          }
          return false;
        },
      ).toList();
    }
    return runningList;
  }

  bool _munroListsEqual(List<Munro> initialList, List<Munro> filteredMunroList) {
    if (initialList.length != filteredMunroList.length) return false;
    for (int i = 0; i < initialList.length; i++) {
      if (initialList[i].id != filteredMunroList[i].id) return false;
    }
    return true;
  }

  List<Munro> _sort(List<Munro> runningList) {
    switch (_sortOrder) {
      case SortOrder.alphabetical:
        runningList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOrder.height:
        runningList.sort((a, b) => b.meters.compareTo(a.meters));
        break;
      case SortOrder.popular:
        runningList.sort((a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0));
        break;
      case SortOrder.rating:
        runningList.sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
        break;
    }
    return runningList;
  }

  List<Munro> _filterOutFilterOptions(List<Munro> runningList) {
    if (_filterOptions.areas.isNotEmpty) {
      runningList = runningList.where((munro) {
        return _filterOptions.areas.contains(munro.area);
      }).toList();
    }

    if (_filterOptions.completed.isNotEmpty) {
      if (_filterOptions.completed.contains('Yes')) {
        runningList = runningList.where((munro) {
          return munro.summited;
        }).toList();
      }
      if (_filterOptions.completed.contains('No')) {
        runningList = runningList.where((munro) {
          return !munro.summited;
        }).toList();
      }
    }

    return runningList;
  }

  List<Munro> _filterOutGroupFilter(List<Munro> runningList) {
    if (_groupFilterMunroIds.isNotEmpty) {
      runningList = runningList.where((munro) {
        return !_groupFilterMunroIds.contains(munro.id);
      }).toList();
    }
    return runningList;
  }
}

enum MunroStatus { initial, loading, loaded, error }
