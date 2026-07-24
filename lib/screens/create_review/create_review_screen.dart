import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/create_review/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreateReviewsScreen extends StatefulWidget {
  const CreateReviewsScreen({super.key});
  static const String route = '/review/create';

  @override
  State<CreateReviewsScreen> createState() => _CreateReviewsScreenState();
}

class _CreateReviewsScreenState extends State<CreateReviewsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<int, int> _ratings = {};
  bool _hasHandledLoaded = false;

  void _goHome(BuildContext context) {
    context.read<MunroState>().clearFilterAndSorting();
    Navigator.pushNamedAndRemoveUntil(
      context,
      HomeScreen.route,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateReviewState>(
      builder: (context, createReviewState, child) {
        switch (createReviewState.status) {
          case CreateReviewStatus.error:
            return SafeArea(
              child: Column(
                children: [
                  CenterText(text: createReviewState.error.message),
                  CtaButton(
                    onPressed: () => _goHome(context),
                    child: const Text("Exit"),
                  ),
                ],
              ),
            );
          case CreateReviewStatus.loaded:
            if (!_hasHandledLoaded) {
              _hasHandledLoaded = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                context.read<OverlayIntentState>().enqueue(const ReviewPromptIntent());
                _goHome(context);
              });
            }
            return const SizedBox();
          default:
            return _buildScreen(context, createReviewState);
        }
      },
    );
  }

  Widget _buildScreen(
      BuildContext context, CreateReviewState createReviewState) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    final munros = createReviewState.munrosToReview;
    final allRated = munros.isNotEmpty &&
        munros.every((munro) => (_ratings[munro.id] ?? 0) > 0);
    final isSubmitting = createReviewState.status == CreateReviewStatus.loading;

    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => _goHome(context)),
              title: Text('Rate Your Climb', style: textTheme.headlineSmall),
              centerTitle: false,
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips & Conditions',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    AppTextFormField(
                      hintText:
                          'e.g. Path conditions, difficulty, weather, advice for future climbers...',
                      maxLines: 5,
                      onSaved: (value) {
                        final text = value?.trim() ?? '';
                        for (final munro in munros) {
                          createReviewState.setMunroReview(munro.id, text);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Rate Each Munro',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...munros.map((Munro munro) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                munro.name,
                                style: textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${munro.meters}m • ${munro.area}',
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: colors.textSubtitle),
                              ),
                              const SizedBox(height: 12),
                              StarRatingFormField(
                                initialValue: createReviewState
                                    .reviews[munro.id]!["rating"],
                                itemSize: 32,
                                spacing: 8,
                                activeColor: colors.starColor,
                                inactiveColor: colors.divider,
                                validator: (rating) {
                                  if (rating == null || rating < 1) {
                                    return 'Please select at least one star';
                                  }
                                  return null;
                                },
                                onChanged: (value) =>
                                    setState(() => _ratings[munro.id] = value),
                                onSaved: (newValue) => createReviewState
                                    .setMunroRating(munro.id, newValue!),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: colors.background,
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: BottomButtonBar(
                child: CtaButton(
                  disabled: isSubmitting || !allRated,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    _formKey.currentState!.save();
                    createReviewState.createReview();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 20),
                      SizedBox(width: 8),
                      Text('Complete'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isSubmitting) const BlockingLoadingOverlay(text: 'Submitting...'),
        ],
      ),
    );
  }
}
