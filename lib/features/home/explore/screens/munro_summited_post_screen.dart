import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/munro_service.dart';
import 'package:two_eight_two/general/services/post_service.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

class MunroSummitedPostScreen extends StatelessWidget {
  final Munro munro;
  MunroSummitedPostScreen({super.key, required this.munro});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Create Post"),
        ),
        body: Consumer<PostState>(
          builder: (context, postState, child) {
            switch (postState.status) {
              case PostStatus.error:
                return CenterText(text: postState.error.message);
              default:
                return _buildScreen(context, postState);
            }
          },
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, PostState postState) {
    return Stack(
      children: [
        ElevatedButton(
          onPressed: () {
            PostService.createPost(context, caption: "This is my new post!", picture: null);
          },
          child: Text("Submitt"),
        ),
        postState.status == PostStatus.submitting ? LoadingWidget() : const SizedBox(),
      ],
    );
  }
}
