import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroCommonlyClimbedWithHorizontal extends StatefulWidget {
  final Munro munro;

  const MunroCommonlyClimbedWithHorizontal({super.key, required this.munro});

  @override
  State<MunroCommonlyClimbedWithHorizontal> createState() => _MunroCommonlyClimbedWithHorizontalState();
}

class _MunroCommonlyClimbedWithHorizontalState extends State<MunroCommonlyClimbedWithHorizontal> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final settingsState = context.read<SettingsState>();

    final List<Munro> commonlyClimbedWith = munroState.munroList
        .where((m) => widget.munro.commonlyClimbedWith.map((e) => e.climbedWithId).contains(m.id))
        .toList();

    if (commonlyClimbedWith.isEmpty) {
      return const SizedBox();
    }

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Often climbed with',
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        if (commonlyClimbedWith.length == 1)
          _MunroClimbedWithCard(munro: commonlyClimbedWith.first, settingsState: settingsState)
        else
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              padEnds: false,
              itemCount: commonlyClimbedWith.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: 15,
                    left: index == 0 ? 15 : 0,
                  ),
                  child: _MunroClimbedWithCard(
                    munro: commonlyClimbedWith[index],
                    settingsState: settingsState,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _MunroClimbedWithCard extends StatelessWidget {
  final Munro munro;
  final SettingsState settingsState;

  const _MunroClimbedWithCard({required this.munro, required this.settingsState});

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final heightText = settingsState.metricHeight ? '${munro.meters}m' : '${munro.feet}ft';

    return GestureDetector(
      onTap: () {
        print('Tapped on ${munro.name}');
        Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: munro));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _isValidUrl(munro.pictureURL)
                ? CachedNetworkImage(
                    imageUrl: munro.pictureURL,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/post_image_placeholder.png',
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/post_image_placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/post_image_placeholder.png',
                    fit: BoxFit.cover,
                  ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      munro.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$heightText • ${munro.area}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
