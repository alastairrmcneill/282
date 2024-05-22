import 'package:flutter/material.dart';

class ClickableStatBox extends StatelessWidget {
  final String count;
  final String progress;
  final String subtitle;
  final Function()? onTap;
  const ClickableStatBox({
    super.key,
    required this.count,
    required this.progress,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 100,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(5),
        ),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: progress,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontSize: 50, fontWeight: FontWeight.w400),
                      children: <TextSpan>[
                        TextSpan(
                          text: count,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
