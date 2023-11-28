import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/comments/services/comments_service.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CommentInputField extends StatelessWidget {
  const CommentInputField({super.key});

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    CommentsState commentsState = Provider.of<CommentsState>(context);
    ScrollController _scrollController = ScrollController();

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Column(
      children: [
        commentsState.status == CommentsStatus.submitting ? LinearProgressIndicator() : const SizedBox(),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              children: [
                CircularProfilePicture(
                  radius: 15,
                  profilePictureURL: userState.currentUser?.profilePictureURL,
                ),
                Expanded(
                  flex: 1,
                  child: Scrollbar(
                    controller: _scrollController,
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        scrollController: _scrollController,
                        initialValue: commentsState.commentText,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Add a comment...",
                        ),
                        minLines: 1,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        onSaved: (value) {
                          commentsState.setCommentText = value!.trim();
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _formKey.currentState!.save();
                    if (commentsState.commentText?.isEmpty ?? true) return;

                    CommentsService.createComment(context);
                  },
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
