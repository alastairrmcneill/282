import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/widgets.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/onboarding/screens/onboarding_notifications_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/onboarding_sign_in_prompt_screen.dart';
import 'package:two_eight_two/screens/onboarding/widgets/onboarding_buttons.dart';

enum _ViewMode { list, map }

// Nav button area height above safe area: 12 (top) + 50 (button) + 24 (bottom) = 86
const double _navAreaHeight = 86;

class OnboardingBulkLogScreenArgs {
  final bool alreadyAuthenticated;
  const OnboardingBulkLogScreenArgs({this.alreadyAuthenticated = false});
}

class OnboardingBulkLogScreen extends StatefulWidget {
  static const String route = '/onboarding/bulk_log';
  const OnboardingBulkLogScreen({super.key, this.alreadyAuthenticated = false});

  /// True when reached from a flow where the user is already signed in
  /// (e.g. in-app onboarding) - skips the sign-in prompt on continue.
  final bool alreadyAuthenticated;

  @override
  State<OnboardingBulkLogScreen> createState() => _OnboardingBulkLogScreenState();
}

class _OnboardingBulkLogScreenState extends State<OnboardingBulkLogScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  _ViewMode _viewMode = _ViewMode.list;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BulkMunroUpdateState>().setStartingBulkMunroUpdateList = [];
      context.read<MunroState>().setBulkMunroUpdateFilterString = '';
      context.read<Analytics>().track(
        AnalyticsEvent.onboardingScreenViewed,
        props: {
          AnalyticsProp.screenIndex: widget.alreadyAuthenticated ? 1 : 5,
          AnalyticsProp.source: widget.alreadyAuthenticated ? 'in_app_onboarding' : 'first_run_onboarding',
        },
      );
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildSegmentedButton(BuildContext context) {
    return UnconstrainedBox(
      child: SizedBox(
        width: 88,
        height: 44,
        child: SegmentedButton<_ViewMode>(
          showSelectedIcon: false,
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(EdgeInsets.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return null;
              return Theme.of(context).scaffoldBackgroundColor;
            }),
          ),
          segments: const [
            ButtonSegment(
              value: _ViewMode.list,
              label: SizedBox.square(
                dimension: 44,
                child: Center(child: Icon(PhosphorIconsRegular.listBullets, size: 20)),
              ),
            ),
            ButtonSegment(
              value: _ViewMode.map,
              label: SizedBox.square(
                dimension: 44,
                child: Center(child: Icon(PhosphorIconsRegular.mapTrifold, size: 20)),
              ),
            ),
          ],
          selected: {_viewMode},
          onSelectionChanged: (value) {
            setState(() => _viewMode = value.first);
            context.read<Analytics>().track(
              AnalyticsEvent.bulkLogViewToggled,
              props: {
                AnalyticsProp.viewMode: value.first.name,
                AnalyticsProp.source: widget.alreadyAuthenticated ? 'in_app_onboarding' : 'first_run_onboarding',
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Log your past summits',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            widget.alreadyAuthenticated
                ? "Select the Munros you've already climbed. We'll save them when you continue."
                : "Select the Munros you've already climbed. We'll save them once you sign in.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.textMuted,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    final munroState = context.watch<MunroState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: AppSearchBar(
              focusNode: _searchFocusNode,
              icon: PhosphorIconsRegular.magnifyingGlass,
              hintText: 'Search Munros...',
              onSearchTap: () {},
              onChanged: (value) => munroState.setBulkMunroUpdateFilterString = value,
              onClear: () {
                munroState.setBulkMunroUpdateFilterString = '';
                context.read<Analytics>().track(
                  AnalyticsEvent.bulkLogSearchCleared,
                  props: {
                    AnalyticsProp.source: widget.alreadyAuthenticated ? 'in_app_onboarding' : 'first_run_onboarding',
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          _buildSegmentedButton(context),
        ],
      ),
    );
  }

  void _onContinue(BuildContext context, int count) {
    context.read<Analytics>().track(
      AnalyticsEvent.bulkLogContinueTapped,
      props: {
        AnalyticsProp.selectedMunroCount: count,
        AnalyticsProp.source: widget.alreadyAuthenticated ? 'in_app_onboarding' : 'first_run_onboarding',
      },
    );
    if (widget.alreadyAuthenticated) {
      Navigator.pushNamed(
        context,
        OnboardingNotificationsScreen.route,
        arguments: const OnboardingNotificationsScreenArgs(fromInAppOnboarding: true),
      );
    } else {
      Navigator.pushNamed(context, OnboardingSignInPromptScreen.route);
    }
  }

  Widget _buildNavButtons(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: OnboardingNavigationButtons(
        onBack: () {
          context.read<Analytics>().track(
            AnalyticsEvent.onboardingBackTapped,
            props: {
              AnalyticsProp.screenIndex: widget.alreadyAuthenticated ? 1 : 5,
              AnalyticsProp.source: widget.alreadyAuthenticated ? 'in_app_onboarding' : 'first_run_onboarding',
            },
          );
          Navigator.pop(context);
        },
        onNext: () => _onContinue(context, count),
        nextText: count > 0 ? 'Continue ($count)' : 'Continue',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final count = context.watch<BulkMunroUpdateState>().addedMunroCompletions.length;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    if (_viewMode == _ViewMode.map) {
      // Use Material (not Scaffold) — Scaffold subtracts safeArea.bottom from
      // the body's max height before the map sees it, preventing full-screen fill.
      // Material gets full-screen tight constraints directly from the Navigator.
      return Material(
        color: scaffoldBg,
        child: Stack(
          children: [
            // Map fills the full physical screen
            Positioned.fill(
              child: BulkMunroMapScreen(bottomPadding: _navAreaHeight),
            ),
            // Header floats at top — SafeArea handles status bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: scaffoldBg,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      _buildSearchRow(context),
                    ],
                  ),
                ),
              ),
            ),
            // Nav buttons float at bottom — SafeArea handles home indicator
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: _buildNavButtons(context, count),
              ),
            ),
          ],
        ),
      );
    }

    // List mode — standard column layout
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchRow(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  itemCount: munroState.bulkMunroUpdateList.length,
                  itemBuilder: (context, index) =>
                      BulkMunroUpdateListTile(munro: munroState.bulkMunroUpdateList[index]),
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                ),
              ),
            ),
            _buildNavButtons(context, count),
          ],
        ),
      ),
    );
  }
}
