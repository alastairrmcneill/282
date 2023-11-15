import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/explore/widgets/widgets.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/munro_service.dart';
import 'package:two_eight_two/general/services/post_service.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

class MunroSummitedPostScreen extends StatelessWidget {
  MunroSummitedPostScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Create Post"),
        ),
        resizeToAvoidBottomInset: true,
        body: Consumer<CreatePostState>(
          builder: (context, createPostState, child) {
            switch (createPostState.status) {
              case CreatePostStatus.error:
                return CenterText(text: createPostState.error.message);
              case CreatePostStatus.loaded:
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pop();
                });
                return const SizedBox();
              default:
                return _buildScreen(context, createPostState);
            }
          },
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, CreatePostState createPostState) {
    return Stack(
      children: [
        Form(
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
                    decoration: InputDecoration(hintText: "Title your hike"),
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
                      contentPadding: const EdgeInsets.all(15),
                    ),
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.text,
                    onSaved: (newValue) {
                      createPostState.setDescription = newValue?.trim();
                    },
                  ),
                  const SizedBox(height: 15),
                  CreatePostImagePicker(),
                  const SizedBox(height: 15),
                  MunroSelector(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      _formKey.currentState!.save();

                      if (createPostState.editingPost == null) {
                        PostService.createPost(context);
                      } else {
                        PostService.editPost(context);
                      }
                      MunroService.markMunrosAsDone(context, munros: createPostState.selectedMunros);
                    },
                    child: Text("Save"),
                  ),
                ],
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
