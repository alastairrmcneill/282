import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroDetailsTabs extends StatefulWidget {
  final Munro munro;
  final ScrollController scrollController;
  const MunroDetailsTabs({super.key, required this.munro, required this.scrollController});

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

        _trackTabViewed(_currentIndex);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackTabViewed(_currentIndex);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _trackTabViewed(int index) {
    String tabName;
    switch (index) {
      case 0:
        tabName = 'Overview';
        break;
      case 1:
        tabName = 'Photos';
        break;
      case 2:
        tabName = 'Reviews';
        break;
      default:
        tabName = 'Unknown';
    }
    context.read<Analytics>().track(
      AnalyticsEvent.munroDetailsTabViewed,
      props: {
        AnalyticsProp.munroId: widget.munro.id.toString(),
        AnalyticsProp.munroName: widget.munro.name,
        AnalyticsProp.tabName: tabName,
      },
    );
  }

  Widget _buildTabContent(Munro munro) {
    switch (_currentIndex) {
      case 0:
        return OverviewTab(munro: munro);
      case 1:
        return PhotosTab(scrollController: widget.scrollController);
      case 2:
        return ReviewsTab(munroId: widget.munro.id, scrollController: widget.scrollController);
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
