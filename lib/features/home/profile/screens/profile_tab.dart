import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/auth/screens/auth_home_screen.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                    ),
                  ],
                ),
              ),
              title: Text(
                userState.currentUser?.displayName ?? "Hello User!",
                style: const TextStyle(color: Colors.black),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.all(16),
              collapseMode: CollapseMode.pin,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.3, color: Colors.black54),
                      color: Colors.white,
                      shape: BoxShape.circle),
                  child: IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(2),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings,
                      size: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // SliverAppBar(
          //   backgroundColor: Colors.white,
          //   foregroundColor: Colors.black,
          //   expandedHeight: 250,
          //   pinned: true,
          //   flexibleSpace: FlexibleSpaceBar(
          //     centerTitle: false,
          //     title: Text(
          //       'Ali',
          //       style: TextStyle(color: Colors.black),
          //     ),
          //     background: SizedBox(
          //       height: 250,
          //       child: Padding(
          //         padding: EdgeInsets.all(80),
          //         child: CircleAvatar(
          //           backgroundColor: Colors.green,
          //           radius: 15,
          //         ),
          //       ),
          //     ),
          //   ),
          //   actions: [
          //     Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 15.0),
          //       child: Container(
          //         decoration: BoxDecoration(
          //             border: Border.all(width: 0.3, color: Colors.black54),
          //             color: Colors.white,
          //             shape: BoxShape.circle),
          //         child: IconButton(
          //           constraints: const BoxConstraints(),
          //           padding: const EdgeInsets.all(2),
          //           onPressed: () {
          //             Navigator.of(context).push(
          //               MaterialPageRoute(
          //                 builder: (_) => const SettingsScreen(),
          //               ),
          //             );
          //           },
          //           icon: Icon(
          //             Icons.settings,
          //             size: 18,
          //             color: Colors.grey[800],
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          SliverToBoxAdapter(
            child: Column(children: [
              Container(
                color: Colors.red,
                height: 200,
              ),
              Container(
                color: Colors.blue,
                height: 200,
              ),
              Container(
                color: Colors.yellow,
                height: 200,
              ),
              Container(
                color: Colors.purple,
                height: 200,
              ),
            ]),
          )
        ],
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.green,
      //   elevation: 0,
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 15.0),
      //       child: Container(
      //         decoration: BoxDecoration(
      //             border: Border.all(width: 0.3, color: Colors.black54),
      //             color: Colors.white,
      //             shape: BoxShape.circle),
      //         child: IconButton(
      //           constraints: const BoxConstraints(),
      //           padding: const EdgeInsets.all(2),
      //           onPressed: () {
      //             Navigator.of(context).push(
      //               MaterialPageRoute(
      //                 builder: (_) => const SettingsScreen(),
      //               ),
      //             );
      //           },
      //           icon: Icon(
      //             Icons.settings,
      //             size: 18,
      //             color: Colors.grey[800],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
