import 'package:flutter/material.dart';

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
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Components'),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemBuilder: (context, index) => widgets[index],
        separatorBuilder: (context, index) => SizedBox(height: 20),
        itemCount: widgets.length,
      ),
    );
  }
}
