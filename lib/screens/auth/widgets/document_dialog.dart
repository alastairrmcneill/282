import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

// Custom error dialog with string input for any message
showDocumentDialog(BuildContext context, {required String mdFileName}) async {
  Dialog dialog = Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    child: Container(
      width: 200.0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(Duration(milliseconds: 150)).then((value) {
                return rootBundle.loadString(mdFileName);
              }),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data!,
                    onTapLink: (text, url, title) async {
                      if (url == null) return;

                      try {
                        await launchUrl(
                          Uri.parse(url),
                        );
                      } on Exception catch (error, stackTrace) {
                        context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
                        Clipboard.setData(ClipboardData(text: url));
                        showSnackBar(context, 'Copied link. Go to browser to open.');
                      }
                    },
                  );
                }
                return const LoadingWidget(text: 'Loading document...');
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text('OK'),
            ),
          ),
        ],
      ),
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return dialog;
    },
  );
}
