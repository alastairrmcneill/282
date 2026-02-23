import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/widgets.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

enum MunroListViewMode { list, map }

class BulkMunroUpdateScreen extends StatefulWidget {
  static const String route = '/bulk_munro_update';
  const BulkMunroUpdateScreen({super.key});

  @override
  State<BulkMunroUpdateScreen> createState() => _BulkMunroUpdateScreenState();
}

class _BulkMunroUpdateScreenState extends State<BulkMunroUpdateScreen> {
  final FocusNode searchFocusNode = FocusNode();
  MunroListViewMode _viewMode = MunroListViewMode.list;

  @override
  void initState() {
    super.initState();
    context.read<AppFlagsRepository>().setShowBulkMunroDialog(false);
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final munroCompletionState = context.watch<MunroCompletionState>();
    final bulkMunroUpdateState = context.watch<BulkMunroUpdateState>();

    final listItems = <Widget>[
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "Select munros you've already completed. Dates will default to today unless you specify otherwise.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
          ),
        ),
      ),
      Row(
        children: [
          Expanded(
            flex: 1,
            child: AppSearchBar(
              focusNode: searchFocusNode,
              icon: PhosphorIconsRegular.magnifyingGlass,
              hintText: "Search munros...",
              onSearchTap: () {},
              onChanged: (value) {
                munroState.setBulkMunroUpdateFilterString = value;
              },
              onClear: () {
                munroState.setBulkMunroUpdateFilterString = '';
              },
            ),
          ),
          const SizedBox(width: 10),
          UnconstrainedBox(
            child: SizedBox(
              width: 88,
              height: 44,
              child: SegmentedButton<MunroListViewMode>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: const [
                  ButtonSegment(
                    value: MunroListViewMode.list,
                    label: SizedBox.square(
                      dimension: 44,
                      child: Center(child: Icon(PhosphorIconsRegular.listBullets, size: 20)),
                    ),
                  ),
                  ButtonSegment(
                    value: MunroListViewMode.map,
                    label: SizedBox.square(
                      dimension: 44,
                      child: Center(child: Icon(PhosphorIconsRegular.mapTrifold, size: 20)),
                    ),
                  ),
                ],
                selected: {_viewMode},
                onSelectionChanged: (newValue) => setState(() => _viewMode = newValue.first),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      ...munroState.bulkMunroUpdateList.map((Munro munro) => BulkMunroUpdateListTile(munro: munro)),
      const SizedBox(height: 10),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Munro Update'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: SizedBox(
              height: 36,
              child: FilledButton(
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(const Size(80, 40)),
                  padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 10, vertical: 0)),
                  backgroundColor: WidgetStateProperty.all(MyColors.accentColor),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);

                  munroCompletionState.addBulkCompletions(
                    munroCompletions: bulkMunroUpdateState.addedMunroCompletions,
                  );
                },
                child: Text("Add (${bulkMunroUpdateState.addedMunroCompletions.length})"),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView.separated(
          itemCount: listItems.length,
          itemBuilder: (context, index) => listItems[index],
          separatorBuilder: (context, index) => const SizedBox(height: 10),
        ),
      ),
    );
  }
}
