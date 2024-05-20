import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreateMunroChallengeScreen extends StatelessWidget {
  CreateMunroChallengeScreen({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementsState>(
      builder: (context, achievementsState, child) {
        switch (achievementsState.status) {
          case AchievementsStatus.error:
            print(achievementsState.error.code);
            return Scaffold(
              appBar: AppBar(
                title: const Text('Update Munro Challenge'),
                centerTitle: false,
              ),
              body: CenterText(text: achievementsState.error.message),
            );
          case AchievementsStatus.loaded:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context);
            });
            return const SizedBox();
          default:
            return _buildScreen(context, achievementsState);
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, AchievementsState achievementsState) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Munro Challenge'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                      'Challenge yourself by setting a goal for how many munros you want to climb in ${DateTime.now().year}.'),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: TextFormFieldBase(
                      initialValue:
                          achievementsState.currentAchievement?.criteria[CriteriaFields.count].toString() ?? '0',
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
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        _formKey.currentState!.save();
                        AchievementService.setMunroChallenge(context);
                      },
                      child: const Text('Create Munro Challenge'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        achievementsState.status == AchievementsStatus.loading
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.8,
                color: Colors.transparent,
                child: const LoadingWidget(),
              )
            : const SizedBox(),
      ],
    );
  }
}
