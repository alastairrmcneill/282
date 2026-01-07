import 'package:flutter/material.dart';

class WhatsNewDialog extends StatelessWidget {
  final String version;
  const WhatsNewDialog({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // TODO: Update when the new version is released.
                      Text(
                        "🎉 New Group Planning view! 🎉",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 13, fontWeight: FontWeight.bold, height: 1.8),
                      ),
                      const SizedBox(height: 20),

                      Text("Struggling to decide which munro to do with your friends?"),
                      const SizedBox(height: 15),
                      Text(
                          "Well now you can simply select them in the Group Planning screen and browse all the munros that none of you have done yet!"),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            "assets/images/whats_new_group_filter.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
