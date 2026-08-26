import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';

class StravaMatchesReviewBottomSheet extends StatelessWidget {
  const StravaMatchesReviewBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StravaMatchesReviewBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stravaActivityReviewState = context.watch<StravaActivityReviewState>();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text('Strava Matches Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // const StravaMatchesReviewBottomSheetHeader(),
              const Divider(thickness: 0.7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(width: double.infinity, child: const CreateNewSavedListWidget(basic: true)),
              ),
              const SizedBox(height: 10),

              // ...StravaActivityReviewState.pendingMunroMatches.map(
              //   (e) => StravaMatchesReviewBottomSheetTile(
              //     StravaActivityReviewState: StravaActivityReviewState,
              //     match: e,
              //   ),
              // ),

              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
