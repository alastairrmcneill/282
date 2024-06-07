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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (createPostState.editingPost == null) {
                  // Send to review page
                  CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);
                  createReviewState.reset();
                  createReviewState.setMunrosToReview = createPostState.selectedMunros;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    HomeScreen.route,
                    (Route<dynamic> route) => false,
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CreateReviewsScreen()));
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
            actions: [
              TextButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  _formKey.currentState!.save();

                  if (createPostState.status == CreatePostStatus.initial) {
                    if (createPostState.editingPost == null) {
                      PostService.createPost(context);
                    } else {
                      PostService.editPost(context);
                    }
                  }
                },
                child: const Text("Save"),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormFieldBase(
                      initialValue: createPostState.title,
                      onSaved: (newValue) {
                        if ((newValue == null || newValue.trim() == "")) {
                          createPostState.setTitle = null;
                        } else {
                          createPostState.setTitle = newValue.trim();
                        }
                      },
                      hintText: "Title your hike",
                    ),
                    const SizedBox(height: 15),
                    TextFormFieldBase(
                      initialValue: createPostState.description,
                      hintText: "How was it? Tell us about your hike.",
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      onSaved: (newValue) {
                        createPostState.setDescription = newValue?.trim();
                      },
                    ),
                    const PaddedDivider(top: 35, bottom: 10),
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
