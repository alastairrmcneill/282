import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/feed/screens/screens.dart';
import 'package:two_eight_two/features/home/profile/screens/profile_screen.dart';
import 'package:two_eight_two/general/models/app_user.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/profile_service.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String query = '';

  void _clearSearch() {
    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchController.clear());
      query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    String currentUserId = userState.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: InputBorder.none,
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, size: 30),
              suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: _clearSearch),
              filled: true,
            ),
            onChanged: (value) {
              if (value.trim().length >= 3) {
                setState(() {
                  query = value.trim().toLowerCase();
                });
              }
            },
          ),
          Expanded(
            flex: 1,
            child: query == ''
                ? const SizedBox()
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .orderBy(AppUserFields.searchName, descending: false)
                        .startAt([query]).endAt(["$query\uf8ff"]).snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final results = snapshot.data!.docs;
                      // TODO Put some pagination in here

                      return ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final AppUser user = AppUser.fromJSON(results[index].data() as Map<String, dynamic>);

                          if (user.uid != currentUserId) {
                            return ListTile(
                              title: Text(user.displayName ?? ""),
                              onTap: () {
                                ProfileService.loadUserFromUid(context, userId: user.uid!);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
