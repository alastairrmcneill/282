import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/create_post/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/saved_list_munro_tile.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  static const String route = '/posts/create1';

  @override
  State<CreatePostScreen> createState() => _CreatePostScreen1State();
}

class _CreatePostScreen1State extends State<CreatePostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _munroError;
  bool _hasHandledLoaded = false;

  @override
  Widget build(BuildContext context) {
    final createPostState = context.read<CreatePostState>();
    return PopScope(
      canPop: createPostState.status != CreatePostStatus.loading,
      child: Consumer<CreatePostState>(
        builder: (context, createPostState, child) {
          switch (createPostState.status) {
            case CreatePostStatus.loaded:
              if (!_hasHandledLoaded) {
                _hasHandledLoaded = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (createPostState.editingPost == null) {
                    final createReviewState = context.read<CreateReviewState>();
                    final munroState = context.read<MunroState>();
                    createReviewState.reset();
                    List<Munro> selectedMunros = munroState.munroList
                        .where((munro) =>
                            createPostState.selectedMunroIds.contains(munro.id))
                        .toList();
                    createReviewState.setMunrosToReview = selectedMunros;
                    Navigator.of(context).pushNamed(CreateReviewsScreen.route);
                  } else {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }
                });
              }
              return const SizedBox();
            default:
              return _buildScreen(context, createPostState);
          }
        },
      ),
    );
  }

  void _showMunroModalSheet() {
    final munroState = context.read<MunroState>();
    final createPostState = context.read<CreatePostState>();
    munroState.setCreatePostFilterString = "";

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            return Consumer<MunroState>(
              builder: (ctx, munroState, child) {
                return ListView(
                  children: [
                    const CreatePostMunroSearchbar(),
                    ...munroState.createPostFilteredMunroList
                        .map((Munro munro) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(munro.name,
                                style: const TextStyle(fontSize: 14)),
                            subtitle: munro.extra == ""
                                ? Text(munro.area)
                                : Text("${munro.extra} - ${munro.area}"),
                            trailing: createPostState.selectedMunroIds
                                    .contains(munro.id)
                                ? const Icon(Icons.check_rounded)
                                : null,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            onTap: () {
                              if (createPostState.selectedMunroIds
                                  .contains(munro.id)) {
                                createPostState.removeMunro(munro.id);
                              } else {
                                createPostState.addMunro(munro.id);
                              }
                              setModalState(() {});
                              setState(() => _munroError = null);
                            },
                          ),
                          const Divider(),
                        ],
                      );
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _retrySubmit(CreatePostState createPostState) {
    if (createPostState.editingPost == null) {
      createPostState.createPost();
    } else {
      createPostState.editPost();
    }
  }

  Future<void> _submitPost(
      BuildContext context, CreatePostState createPostState) async {
    // Guard against double-submission (e.g. rapid double-tap)
    if (createPostState.status != CreatePostStatus.initial) return;

    // Validate munro selection
    if (createPostState.selectedMunroIds.isEmpty) {
      setState(() => _munroError = "Select at least one munro.");
      return;
    }
    setState(() => _munroError = null);

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (!createPostState.hasImage) {
      context
          .read<Analytics>()
          .track(AnalyticsEvent.createPostNoPhotosDialogShown);
      bool? carryOn = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => const NoPhotosDialog(),
      );
      if (carryOn == null || carryOn == false) return;
    }

    if (createPostState.status == CreatePostStatus.initial) {
      if (createPostState.editingPost == null) {
        createPostState.createPost();
      } else {
        final updated = await createPostState.editPost();
        if (updated != null) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop<Post>(updated);
          }
        }
      }
    }
  }

  Widget _buildScreen(BuildContext context, CreatePostState createPostState) {
    final munroState = context.watch<MunroState>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Create Post'),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                if (createPostState.status == CreatePostStatus.error)
                  MaterialBanner(
                    content: Text(createPostState.error.message),
                    actions: [
                      TextButton(
                        onPressed: () => _retrySubmit(createPostState),
                        child: const Text('Try Again'),
                      ),
                      TextButton(
                        onPressed: () => createPostState.setStatus =
                            CreatePostStatus.initial,
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // --- Munros Section Header ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Munros',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: _showMunroModalSheet,
                                child: Text(
                                  '+ Add Munro',
                                  style: TextStyle(
                                      color: context.colors.accent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // --- Selected Munros List ---
                          ...createPostState.selectedMunroIds
                              .map((int munroId) {
                            final munro = munroState.munroList.firstWhere(
                              (m) => m.id == munroId,
                              orElse: () => Munro.empty,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SavedListMunroTile(
                                munro: munro,
                                onDelete: () async {
                                  createPostState.removeMunro(munro.id);
                                  setState(() {});
                                },
                              ),
                            );
                          }),
                          if (_munroError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _munroError!,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12),
                              ),
                            ),

                          // --- Description Field ---
                          const Divider(height: 32),

                          const SizedBox(height: 12),
                          AppTextFormField(
                            initialValue: createPostState.description,
                            hintText: "Share your experience...",
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            keyboardType: TextInputType.text,
                            onSaved: (newValue) {
                              createPostState.setDescription = newValue?.trim();
                            },
                            fillColor: Colors.white,
                          ),

                          const SizedBox(height: 12),
                          const CreatePostSummitDatePicker(),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Expanded(
                                  flex: 1, child: CreatePostSummitTimePicker()),
                              const SizedBox(width: 10),
                              const Expanded(
                                  flex: 1, child: CreatePostDurationPicker()),
                            ],
                          ),

                          // const Divider(height: 32),

                          // // --- Munros Summited Section ---
                          // Text(
                          //   'Photos',
                          //   style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                          // ),
                          const SizedBox(height: 12),
                          ...createPostState.selectedMunroIds
                              .map((int munroId) {
                            final munro = munroState.munroList.firstWhere(
                              (m) => m.id == munroId,
                              orElse: () => Munro.empty,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined,
                                            color: Colors.grey.shade600,
                                            size: 24),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(munro.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500)),
                                            Text(
                                              '${munro.meters}m • ${munro.area}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      color: context
                                                          .colors.textMuted),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    CreatePostImagePicker(munroId: munro.id),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 20),
                          PostPrivacySelector(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomButtonBar(
            child: PrimaryButton(
              analyticsEvent: AnalyticsEvent.createPostBagMunroButtonPressed,
              onPressed: createPostState.status == CreatePostStatus.initial
                  ? () => _submitPost(context, createPostState)
                  : null,
              child: Text(
                'Bag Munro${createPostState.selectedMunroIds.length > 1 ? 's' : ''}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        if (createPostState.status == CreatePostStatus.loading)
          const BlockingLoadingOverlay(text: 'Uploading...'),
      ],
    );
  }
}
