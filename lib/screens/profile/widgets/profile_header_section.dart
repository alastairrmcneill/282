import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileState>();
    final currentUserFollowerState = context.watch<CurrentUserFollowerState>();
    final profile = profileState.profile;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          CircularProfilePicture(
            radius: 40,
            profilePictureURL: profile?.profilePictureURL,
          ),
          const SizedBox(height: 12),
          _FollowerStats(
            followersCount: profile?.followersCount ?? 0,
            followingCount: profile?.followingCount ?? 0,
            userId: profile?.id ?? '',
          ),
          if ((profile?.bio ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              profile!.bio!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          if (profileState.isCurrentUser)
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed(EditProfileScreen.route),
              child: const Text('Edit Profile'),
            )
          else
            _OtherProfileButtons(
              isFollowing: currentUserFollowerState.isFollowing(profile?.id ?? ''),
              profile: profile,
            ),
        ],
      ),
    );
  }
}

class _FollowerStats extends StatelessWidget {
  final int followersCount;
  final int followingCount;
  final String userId;

  const _FollowerStats({
    required this.followersCount,
    required this.followingCount,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            FollowersFollowingScreen.route,
            arguments: FollowersFollowingScreenArgs(userId: userId),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$followersCount',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                ),
                TextSpan(
                  text: ' followers',
                  style: textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('·', style: textTheme.bodyMedium?.copyWith(color: context.colors.border)),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            FollowersFollowingScreen.route,
            arguments: FollowersFollowingScreenArgs(userId: userId),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$followingCount',
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: context.colors.textPrimary),
                ),
                TextSpan(
                  text: ' following',
                  style: textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OtherProfileButtons extends StatelessWidget {
  final bool isFollowing;
  final dynamic profile;

  const _OtherProfileButtons({required this.isFollowing, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FollowingButton(isFollowing: isFollowing, profile: profile),
    );
  }
}
