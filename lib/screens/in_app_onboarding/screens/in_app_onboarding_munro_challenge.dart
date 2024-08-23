import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class InAppOnboardingMunroChallenge extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const InAppOnboardingMunroChallenge({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Challenge yourself by setting a goal for how many munros you want to climb in ${DateTime.now().year}.'),
          const SizedBox(height: 30),
          Form(
            key: formKey,
            child: TextFormFieldBase(
              initialValue: achievementsState.currentAchievement?.criteria[CriteriaFields.count].toString() ?? '0',
              labelText: "Number of Munros",
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null ||
                    int.parse(value) < 1 ||
                    int.parse(value) > 282) {
                  return 'Please enter a number between 1 and 282.';
                }
                return null;
              },
              onSaved: (value) {
                achievementsState.currentAchievement?.criteria[CriteriaFields.count] = int.parse(value!);
              },
            ),
          ),
          // SizedBox(
          //   height: 44,
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       if (!_formKey.currentState!.validate()) {
          //         return;
          //       }
          //       _formKey.currentState!.save();
          //       AchievementService.setMunroChallenge(context);
          //     },
          //     child: const Text('Create Munro Challenge'),
          //   ),
          // ),
        ],
      ),
    );
  }
}
