import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:two_eight_two/extensions/extensions.dart";
import "package:two_eight_two/models/models.dart";
import "package:two_eight_two/screens/create_review/widgets/widgets.dart";
import "package:two_eight_two/screens/notifiers.dart";
import "package:two_eight_two/widgets/widgets.dart";

class EditReviewScreen extends StatefulWidget {
  const EditReviewScreen({super.key});
  static const String route = '/review/edit';

  @override
  State<EditReviewScreen> createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hasHandledLoaded = false;
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = context.read<CreateReviewState>().currentMunroRating;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateReviewState>(
      builder: (context, createReviewState, child) {
        switch (createReviewState.status) {
          case CreateReviewStatus.error:
            return Scaffold(
              appBar: AppBar(),
              body: SafeArea(
                child: Column(
                  children: [
                    CenterText(text: createReviewState.error.message),
                    CtaButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Exit"),
                    ),
                  ],
                ),
              ),
            );
          case CreateReviewStatus.loaded:
            if (!_hasHandledLoaded) {
              _hasHandledLoaded = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              });
            }
            return const Scaffold();
          default:
            return _buildScreen(context, createReviewState);
        }
      },
    );
  }

  Widget _buildScreen(
      BuildContext context, CreateReviewState createReviewState) {
    final munroState = context.read<MunroState>();
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    final isSubmitting = createReviewState.status == CreateReviewStatus.loading;

    Munro munro = munroState.munroList.firstWhere(
      (element) => element.id == createReviewState.editingReview!.munroId,
      orElse: () => Munro.empty,
    );

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Edit Review', style: textTheme.headlineSmall),
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
                    initialValue: createReviewState.currentMunroReview,
                    hintText:
                        'e.g. Path conditions, difficulty, weather, advice for future climbers...',
                    maxLines: 5,
                    onSaved: (value) {
                      createReviewState.setCurrentMunroReview =
                          value?.trim() ?? "";
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Rate This Munro',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
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
                            initialValue: createReviewState.currentMunroRating,
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
                                setState(() => _rating = value),
                            onSaved: (newValue) => createReviewState
                                .setCurrentMunroRating = newValue!,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                disabled: isSubmitting || _rating < 1,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  _formKey.currentState!.save();
                  createReviewState.editReview(
                    onReviewUpdated: (newReview) =>
                        context.read<ReviewsState>().replaceReview = newReview,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 20),
                    SizedBox(width: 8),
                    Text('Save Changes'),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isSubmitting) const BlockingLoadingOverlay(text: 'Submitting...'),
      ],
    );
  }
}
