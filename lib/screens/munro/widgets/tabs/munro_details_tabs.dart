import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroDetailsTabs extends StatefulWidget {
  final Munro munro;
  const MunroDetailsTabs({super.key, required this.munro});

  @override
  State<MunroDetailsTabs> createState() => _MunroDetailsTabsState();
}

class _MunroDetailsTabsState extends State<MunroDetailsTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      if (_currentIndex != _tabController.index) {
        setState(() {
          _currentIndex = _tabController.index;
        });

        // _trackTabViewed(_currentIndex);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabContent(Munro munro) {
    switch (_currentIndex) {
      case 0:
        return OverviewTab(munro: munro);
      case 1:
        return PhotosTab();
      case 2:
        return ReviewsTab();
      default:
        return OverviewTab(munro: munro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          dividerHeight: 0.7,
          dividerColor: Colors.grey[300],
          labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500, height: 1),
          labelColor: MyColors.accentColor,
          unselectedLabelColor: MyColors.mutedText,
          indicatorColor: MyColors.accentColor,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: UnderlineTabIndicator(
            insets: const EdgeInsets.symmetric(horizontal: 8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
            borderSide: BorderSide(
              color: MyColors.accentColor,
              width: 3,
            ),
          ),
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Photos'),
            Tab(text: 'Reviews'),
          ],
        ),
        _buildTabContent(widget.munro),
      ],
    );
  }
}
