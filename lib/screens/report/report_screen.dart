import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReportScreen extends StatelessWidget {
  ReportScreen({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const String route = '/report';

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportState>(
      builder: (context, reportState, child) {
        switch (reportState.status) {
          case ReportStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ReportStatus.error:
            return Scaffold(
              appBar: AppBar(),
              body: CenterText(text: reportState.error.message),
            );
          case ReportStatus.loaded:
            return Scaffold(
              appBar: AppBar(),
              body: const CenterText(text: "Report sent successfully"),
            );
          default:
            return _buildScreen(context, reportState);
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, ReportState reportState) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Please provide an explanation for why you are reporting this content.",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 15),
                    TextFormFieldBase(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a comment";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        reportState.setComment = value!;
                      },
                      maxLines: 5,
                      hintText: "Comment",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    _formKey.currentState!.save();

                    reportState.sendReport();
                  },
                  child: const Text("Report"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
