import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

class DurationPickerDialog extends StatefulWidget {
  final Duration initialDuration;

  const DurationPickerDialog({super.key, this.initialDuration = Duration.zero});

  @override
  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  int _hours = 0;
  int _minutes = 0;
  final FixedExtentScrollController _hourController = FixedExtentScrollController();
  final FixedExtentScrollController _minuteController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDuration.inHours;
    _minutes = widget.initialDuration.inMinutes % 60;
    _hourController.jumpToItem(_hours);
    _minuteController.jumpToItem(_minutes);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 300,
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Duration',
                  style: TextStyle(fontSize: 14, color: MyColors.textColor),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFlatPicker(_hours, 23, (value) {
                        setState(() {
                          _hours = value;
                        });
                      }, 'h', _hourController, _hours),
                    ),
                    Expanded(
                      child: _buildFlatPicker(_minutes, 59, (value) {
                        setState(() {
                          _minutes = value;
                        });
                      }, 'm', _minuteController, _minutes),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final duration = Duration(
                      hours: _hours,
                      minutes: _minutes,
                    );
                    Navigator.of(context).pop(duration);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlatPicker(int currentValue, int maxValue, ValueChanged<int> onSelectedItemChanged, String unit,
      FixedExtentScrollController controller, int selectedValue) {
    return Stack(
      children: [
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 80.0,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: onSelectedItemChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index > maxValue) return null;
              final isSelected = index == selectedValue;
              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 24,
                    color: isSelected ? MyColors.textColor : Colors.grey,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              );
            },
            childCount: maxValue + 1,
          ),
        ),
        _buildSelectionOverlay(),
        Positioned(
          right: 20,
          top: 0,
          bottom: 0,
          child: Center(
            child: Text(
              unit,
              style: const TextStyle(fontSize: 24, color: MyColors.textColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionOverlay() {
    return const IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
          SizedBox(height: 54.0), // Spacing to match the picker item height (80.0) minus divider
          Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }
}
