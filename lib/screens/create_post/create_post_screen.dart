import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/create_post/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

import '../screens.dart';

class CreatePostScreen extends StatelessWidget {
  CreatePostScreen({super.key});

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
              print("Loaded");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                print("Pop screen");
                Navigator.of(context).pop();
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
            actions: [
              TextButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  _formKey.currentState!.save();

                  if (createPostState.status == CreatePostStatus.initial) {
                    if (createPostState.editingPost == null) {
                      // PostService.createPost(context);
                      CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);
                      createReviewState.reset();
                      createReviewState.setMunrosToReview = createPostState.selectedMunros;
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateReviewScreen()));
                    } else {
                      // PostService.editPost(context);
                    }
                  }
                },
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: createPostState.title,
                      decoration: const InputDecoration(hintText: "Title your hike"),
                      textCapitalization: TextCapitalization.sentences,
                      onSaved: (newValue) {
                        if ((newValue == null || newValue.trim() == "")) {
                          createPostState.setTitle = null;
                        } else {
                          createPostState.setTitle = newValue.trim();
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      initialValue: createPostState.description,
                      decoration: const InputDecoration(
                        hintText: "How was it? Tell us about your hike.",
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.all(15),
                      ),
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      onSaved: (newValue) {
                        createPostState.setDescription = newValue?.trim();
                      },
                    ),
                    const SizedBox(height: 15),
                    const CreatePostImagePicker(),
                    const SizedBox(height: 15),
                    const MunroSelector(),
                    const SizedBox(height: 10),
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
      ],
    );
  }
}
