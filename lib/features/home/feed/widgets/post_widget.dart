import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/explore/screens/munro_summited_post_screen.dart';
import 'package:two_eight_two/features/home/widgets/widgets.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/post_service.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  const PostWidget({super.key, required this.post});

  Widget _buildIncludedMunroText() {
    if (post.includedMunros.isEmpty) {
      return const SizedBox();
    } else if (post.includedMunros.length == 1) {
      return Text(post.includedMunros[0].name);
    } else {
      String text = "";
      int len = post.includedMunros.length - 1;
      text = "${post.includedMunros[0].name} + $len more.";
      return Text(text);
    }
  }

  Widget _buildPopUpMenu(
    BuildContext context, {
    required Post post,
    required UserState userState,
    required CreatePostState createPostState,
  }) {
    if (post.authorId == userState.currentUser?.uid) {
      return PopupMenuButton(
        icon: Icon(Icons.more_vert_rounded),
        onSelected: (value) async {
          if (value == MenuItems.item1) {
            createPostState.reset();
            createPostState.loadPost = post;
            Navigator.push(context, MaterialPageRoute(builder: (_) => MunroSummitedPostScreen()));
          } else if (value == MenuItems.item2) {
            PostService.deletePost(context, post: post);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: MenuItems.item1,
            child: Text('Edit'),
          ),
          PopupMenuItem(
            value: MenuItems.item2,
            child: Text('Delete'),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    UserState userState = Provider.of<UserState>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: double.infinity,
        color: Colors.grey[100],
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProfilePicture(
                      radius: 15,
                      profilePictureURL: post.authorProfilePictureURL,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.authorDisplayName),
                        _buildIncludedMunroText(),
                      ],
                    ),
                  ],
                ),
                _buildPopUpMenu(
                  context,
                  userState: userState,
                  createPostState: createPostState,
                  post: post,
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                post.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: post.imageURLs.map((url) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        print('Tapped');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.favorite_outline_rounded),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    indent: 5,
                    endIndent: 5,
                    width: 0.5,
                    color: Colors.grey[500],
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        print('Tapped');
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.comment_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MenuItems {
  item1,
  item2,
  item3;
}
