import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/create_post/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

import '../screens.dart';

class CreatePostScreen extends StatelessWidget {
  CreatePostScreen({super.key});
  static const String route = '/posts/create';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        CreatePostState createPostState = Provider.of<CreatePostState>(context, listen: false);
        return createPostState.status != CreatePostStatus.loading;
      },
      child: Consumer<CreatePostState>(
        builder: (context, createPostState, child) {
          switch (createPostState.status) {
            case CreatePostStatus.error:
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Create Post'),
                  centerTitle: false,
                ),
                body: CenterText(text: createPostState.error.message),
              );
            case CreatePostStatus.loaded:
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (createPostState.editingPost == null) {
                  // Send to review page
                  CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);
                  MunroState munroState = Provider.of<MunroState>(context, listen: false);
                  createReviewState.reset();
                  List<Munro> selectedMunros = munroState.munroList
                      .where((munro) => createPostState.selectedMunroIds.contains(munro.id))
                      .toList();
                  createReviewState.setMunrosToReview = selectedMunros;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    HomeScreen.route,
                    (Route<dynamic> route) => false,
                  );
                  Navigator.of(context).pushNamed(CreateReviewsScreen.route);
                } else {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              });
              return const SizedBox();
            default:
              return _buildScreen(context, createPostState);
          }
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, CreatePostState createPostState) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Create Post'),
            centerTitle: false,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // TextFormFieldBase(
                    //   initialValue: createPostState.title,
                    //   onSaved: (newValue) {
                    //     if ((newValue == null || newValue.trim() == "")) {
                    //       createPostState.setTitle = null;
                    //     } else {
                    //       createPostState.setTitle = newValue.trim();
                    //     }
                    //   },
                    //   hintText: "Title your hike",
                    // ),
                    // const SizedBox(height: 15),
                    TextFormFieldBase(
                      initialValue: createPostState.description,
                      hintText: "How was it? Tell us about your hike.",
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      onSaved: (newValue) {
                        createPostState.setDescription = newValue?.trim();
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hike Stats',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const CreatePostSummitDatePicker(),
                    const SizedBox(height: 10),
                    const CreatePostSummitTimePicker(),
                    const SizedBox(height: 10),
                    const CreatePostDurationPicker(),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Munros summited',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const MunroSelector(),
                    const SizedBox(height: 20),
                    PostPrivacySelector(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
        createPostState.status == CreatePostStatus.loading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                color: Colors.transparent,
                child: const LoadingWidget(),
              )
            : const SizedBox(),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: FloatingActionButton.extended(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _formKey.currentState!.save();

                if (!createPostState.hasImage) {
                  AnalyticsService.logCreatePostNoPhotos();
                  bool? carryOn = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top icon with animation
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 50,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Fun title
                              Text(
                                'Oops, No Photos!',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              // Informative text with a playful tone
                              Text(
                                'Would you like to add some awesome photos to your post before sharing your adventure?',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              // Fun buttons with color and icons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red.shade400,
                                    ),
                                    icon: const Icon(Icons.cancel_rounded),
                                    label: const Text('No, Skip'),
                                    onPressed: () {
                                      AnalyticsService.logCreatePostNoPhotosResponse("skip");
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.check_circle_rounded),
                                    label: const Text('Yes, Add!'),
                                    onPressed: () {
                                      AnalyticsService.logCreatePostNoPhotosResponse("add");
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  if (carryOn == null || carryOn == false) return;
                }

                if (createPostState.status == CreatePostStatus.initial) {
                  if (createPostState.editingPost == null) {
                    PostService.createPost(context);
                  } else {
                    PostService.editPost(context);
                  }
                }
              },
              label: Text(
                'Bag Munro${createPostState.selectedMunroIds.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
              ),
              icon: const Icon(Icons.hiking_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
