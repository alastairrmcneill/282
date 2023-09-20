import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/models.dart';

class MunroBottomSheet extends StatelessWidget {
  final Munro munro;
  const MunroBottomSheet({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     spreadRadius: 0,
        //     blurRadius: 10,
        //     offset: const Offset(0, -1),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            munro.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          munro.extra != ""
              ? Text(
                  '(${munro.extra})',
                )
              : const SizedBox(),
          const Text('Not summited yet'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Height: ${munro.meters}m"),
                    Text("Area: ${munro.area}"),
                    Text("More Info..."),
                  ],
                ),
              ),
              Container(
                color: Colors.grey[300],
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.3,
                child: Image.network(
                  "https://d3teiib5p3f439.cloudfront.net/munros/carn-liath-creag-meagaidh-1.JPG",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
