import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentScreenArgs {
  final String title;
  final String mdFileName;
  DocumentScreenArgs({required this.title, required this.mdFileName});
}

class DocumentScreen extends StatelessWidget {
  final DocumentScreenArgs args;
  const DocumentScreen({super.key, required this.args});
  static const String route = 'settings/document';

  @override
  Widget build(BuildContext context) {
    String title = args.title;
    String mdFileName = args.mdFileName;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                            Log.error(error.toString(), stackTrace: stackTrace);
                            Clipboard.setData(ClipboardData(text: url));
                            showSnackBar(context, 'Copied link. Go to browser to open.');
                          }
                        },
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('OK'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
