import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/component_library/components/app_text_form_field.dart';
import 'package:two_eight_two/screens/component_library/components/cta_button.dart';
import 'package:two_eight_two/screens/component_library/components/pill_button.dart';
import 'package:two_eight_two/screens/component_library/components/primary_button.dart';
import 'package:two_eight_two/screens/component_library/components/primary_icon_button.dart';
import 'package:two_eight_two/screens/component_library/components/secondary_button.dart';

class DesignSystemTab extends StatelessWidget {
  static const String route = '/design-system';

  const DesignSystemTab({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      Text('Headline Large', style: Theme.of(context).textTheme.headlineLarge),
      Text('Headline Medium', style: Theme.of(context).textTheme.headlineMedium),
      Text('Headline Small', style: Theme.of(context).textTheme.headlineSmall),
      Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
      Text('Title Medium', style: Theme.of(context).textTheme.titleMedium),
      Text('Title Small', style: Theme.of(context).textTheme.titleSmall),
      Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
      Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
      Text('Body Small', style: Theme.of(context).textTheme.bodySmall),
      Text('Label Large', style: Theme.of(context).textTheme.labelLarge),
      Text('Label Medium', style: Theme.of(context).textTheme.labelMedium),
      Text('Label Small', style: Theme.of(context).textTheme.labelSmall),
      CtaButton(
        analyticsEvent: 'cta_button_pressed',
        analyticsProperties: {'source': 'design_system_tab'},
        onPressed: () {
          print('CTA Button Pressed');
        },
        child: const Text('Mark as Complete'),
      ),
      CtaButton(
        disabled: true,
        onPressed: () {
          print('CTA Button Pressed');
        },
        child: const Text('Mark as Complete'),
      ),
      PrimaryButton(
        analyticsEvent: 'primary_button_pressed',
        analyticsProperties: {'source': 'design_system_tab'},
        onPressed: () {
          print('Primary Button Pressed');
        },
        child: const Text('Continue'),
      ),
      PrimaryButton(
        disabled: true,
        onPressed: () {
          print('Primary Button Pressed');
        },
        child: const Text('Continue'),
      ),
      SecondaryButton(
        analyticsEvent: 'secondary_button_pressed',
        analyticsProperties: {'source': 'design_system_tab'},
        onPressed: () {
          print('Secondary Button Pressed');
        },
        child: const Text('Create new list'),
      ),
      SecondaryButton(
        disabled: true,
        onPressed: () {
          print('Secondary Button Pressed');
        },
        child: const Text('Create new list'),
      ),
      AppTextFormField(
        hintText: 'Hint Text',
      ),
      AppTextFormField(
        hintText: 'Email',
        prefixIcon: Icon(PhosphorIconsRegular.envelopeSimple),
      ),
      AppTextFormField(
        hintText: 'Password',
        prefixIcon: Icon(PhosphorIconsRegular.lock),
        obscureText: true,
        suffixIcon: Icon(PhosphorIconsRegular.eyeSlash),
      ),
      Row(
        spacing: 16,
        children: [
          PrimaryIconButton(
            onPressed: () {
              print('Icon button pressed');
            },
            icon: Icon(
              PhosphorIconsRegular.arrowSquareOut,
              color: context.colors.accent,
              size: 20,
            ),
          ),
          PrimaryIconButton(
            onPressed: () {
              print('Icon button pressed');
            },
            icon: Icon(
              PhosphorIconsRegular.funnel,
              color: context.colors.textSubtitle,
              size: 20,
            ),
          ),
          PillButton(
            onPressed: () {
              print('Icon button pressed');
            },
            icon: Icon(PhosphorIconsRegular.funnel),
            label: 'Filter',
          ),
        ],
      ),
      DefaultTabController(
        length: 3,
        child: TabBar(
          tabs: [
            Tab(text: 'Tab 1'),
            Tab(text: 'Tab 2'),
            Tab(text: 'Tab 3'),
          ],
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Components'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: widgets[index],
                ),
                childCount: widgets.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
