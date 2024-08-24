import 'package:flutter/material.dart';
import 'package:two_eight_two/services/services.dart';

class WhatsNewDialog extends StatefulWidget {
  final Widget child;

  const WhatsNewDialog({required this.child, super.key});

  @override
  _WhatsNewDialogState createState() => _WhatsNewDialogState();
}

class _WhatsNewDialogState extends State<WhatsNewDialog> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    _checkAndShowDialog();
  }

  void _checkAndShowDialog() async {
    if (_hasShownDialog) return;
    _hasShownDialog = true;

    String version = "1.2.1";
    // Check if dialog has been shown before
    bool showWhatsNewDialog = await SharedPreferencesService.getShowWhatsNewDialog(version);

    if (!showWhatsNewDialog) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSurveyDialog(context, version: version);
    });
  }

  void _showSurveyDialog(BuildContext context, {required String version}) {
    List<String> updates = [
      "Improved munro search with added filters and sorting.",
      "New list view for browsing munros.",
      "New Global feed to see what other munro baggers are up to.",
      "Improved onboarding flow to set previously climbed munros and a challenge for this year.",
      "Improved privacy controls.",
      "Bug fixes.",
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          onPopInvoked: (didPop) {
            if (didPop) {
              // Mark shared prefs as seen
              SharedPreferencesService.setShownWhatsNewDialog(version);
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What's new in v$version:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 13, fontWeight: FontWeight.bold, height: 1.8),
                            ),
                            const SizedBox(height: 5),
                            ...updates.map(
                              (update) => Text(
                                "• $update",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, height: 1.8),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (_) => const WhatsNewScreen()),
                        // );
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
