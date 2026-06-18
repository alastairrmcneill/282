import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class ChallengeGoalSelector extends StatefulWidget {
  final int goal;
  final ValueChanged<int> onChanged;

  const ChallengeGoalSelector({
    super.key,
    required this.goal,
    required this.onChanged,
  });

  @override
  State<ChallengeGoalSelector> createState() => _ChallengeGoalSelectorState();
}

class _ChallengeGoalSelectorState extends State<ChallengeGoalSelector> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  String get _motivationalMessage {
    if (widget.goal <= 12) return 'A steady pace — perfect for savoring each summit';
    if (widget.goal <= 24) return 'Ambitious! Get out there and have some fun!';
    if (widget.goal <= 52) return 'Epic! You\'ll be busy this year!';
    if (widget.goal <= 100) return 'Legendary status incoming!';
    return 'The ultimate Munroist! A truly monumental challenge!';
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.goal}');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ChallengeGoalSelector old) {
    super.didUpdateWidget(old);
    if (old.goal != widget.goal && !_focusNode.hasFocus) {
      _controller.text = '${widget.goal}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commitValue();
  }

  void _onTextChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 1 && parsed <= 282) {
      widget.onChanged(parsed);
    }
  }

  void _commitValue() {
    final parsed = int.tryParse(_controller.text);
    final clamped = (parsed ?? widget.goal).clamp(1, 282);
    if (clamped != widget.goal) widget.onChanged(clamped);
    _controller.text = '$clamped';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Annual Goal',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border, width: 0.65),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepButton(
                    label: '−',
                    onPressed: widget.goal > 1
                        ? () {
                            final next = widget.goal - 1;
                            widget.onChanged(next);
                            _controller.text = '$next';
                          }
                        : null,
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          onChanged: _onTextChanged,
                          onSubmitted: (_) => _commitValue(),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      Text(
                        'munros',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  _StepButton(
                    label: '+',
                    onPressed: widget.goal < 282
                        ? () {
                            final next = widget.goal + 1;
                            widget.onChanged(next);
                            _controller.text = '$next';
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _motivationalMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.accent,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _StepButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          side: BorderSide(color: context.colors.border, width: 0.65),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w300,
                height: 1,
              ),
        ),
      ),
    );
  }
}
