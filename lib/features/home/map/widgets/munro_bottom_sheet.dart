import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroBottomSheet extends StatefulWidget {
  final Munro munro;
  const MunroBottomSheet({super.key, required this.munro});

  @override
  State<MunroBottomSheet> createState() => _MunroBottomSheetState();
}

class _MunroBottomSheetState extends State<MunroBottomSheet> {
  Widget _buildBorder() {
    return Positioned(
      right: -3,
      left: -3,
      top: 0,
      bottom: 100,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: widget.munro.completed ? Colors.green[600] : Colors.red[300],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        width: MediaQuery.of(context).size.height * 0.1,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[500],
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  Widget _buildNameAndArea(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.munro.name,
          textAlign: TextAlign.center,
          // style: Theme.of(context).textTheme.headlineSmall,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        widget.munro.extra != ""
            ? Text(
                '(${widget.munro.extra})',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget _buildAreaAndHeight(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            widget.munro.area,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: "NotoSans",
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.06),
          child: const Text(
            '•',
            style: TextStyle(
              fontFamily: "NotoSans",
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${widget.munro.meters}m',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: "NotoSans",
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.network(
        widget.munro.pictureURL,
        width: double.infinity,
        height: MediaQuery.of(context).size.width * 0.4,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "${widget.munro.description} ",
        style: const TextStyle(
          fontFamily: "NotoSans",
          fontWeight: FontWeight.w300,
          color: Colors.black,
        ),
        children: <TextSpan>[
          TextSpan(
            text: 'Read more.',
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                await launchUrl(
                  Uri.parse(widget.munro.link),
                );
              },
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    // return SlideAction(
    //   innerColor: Colors.grey[100],
    //   outerColor: Colors.green[600],
    //   text: "Slide to summit",
    //   height: 40,
    //   sliderButtonIconPadding: 6,
    //   sliderButtonIconSize: 20,
    //   onSubmit: () {
    //     setState(() {
    //       widget.munro.completed = true;
    //     });
    //   },
    //   sliderRotate: false,
    //   elevation: 3,
    // );
    // return SwipeableButtonView(
    //   buttonText: 'Slide to Complete',
    //   buttonWidget: Container(
    //     child: Icon(
    //       Icons.arrow_forward_ios_rounded,
    //       color: Colors.grey,
    //     ),
    //   ),
    //   activeColor: Color(0xFF009C41),
    //   isFinished: widget.munro.completed,
    //   onWaitingProcess: () {
    //     setState(() {
    //       widget.munro.completed = true;
    //     });
    //   },
    //   onFinish: () {
    //     setState(() {
    //       widget.munro.completed = true;
    //     });
    //   },
    // );
    return Column(
      children: [
        Text(
          widget.munro.completed ? "Bagged it!" : "Bagged it?",
          style: const TextStyle(
            fontFamily: "NotoSans",
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 50,
          height: 50,
          decoration: widget.munro.completed
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[600],
                )
              : BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red[400]!,
                    width: 2.0,
                  ),
                ),
          child: Center(
            child: IconButton(
              onPressed: () {
                setState(() {
                  widget.munro.completed = !widget.munro.completed;

                  MunroService.updateMunro(context, munro: widget.munro);
                });
              },
              icon: Icon(
                widget.munro.completed ? Icons.check : Icons.close,
                size: 30,
                color: widget.munro.completed ? Colors.grey[100] : Colors.red[400]!,
              ),
            ),
          ),
        ),
      ],
    );

    // return ElevatedButton(
    //   style: ButtonStyle(
    //     backgroundColor: MaterialStateProperty.all<Color?>(Colors.red[400]),
    //   ),
    //   onPressed: () {},
    //   child: const Text(
    //     'Bagged it!',
    //     style: TextStyle(
    //       fontFamily: "NotoSans",
    //       fontWeight: FontWeight.w600,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBorder(),
        Container(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                _buildHandle(context),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildNameAndArea(context),
                        const SizedBox(height: 10),
                        _buildAreaAndHeight(context),
                        const SizedBox(height: 10),
                        _buildImage(context),
                        const SizedBox(height: 5),
                        _buildDescription(context),
                        const SizedBox(height: 10),
                        _buildButton(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
