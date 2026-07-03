import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarRatingFormField extends FormField<int> {
  StarRatingFormField({
    super.key,
    super.onSaved,
    super.validator,
    int super.initialValue = 0,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    double itemSize = 40,
    double spacing = 0,
    Color activeColor = Colors.amber,
    Color? inactiveColor,
    ValueChanged<int>? onChanged,
  }) : super(
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<int> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBar(
                  initialRating: initialValue.toDouble(),
                  minRating: 1,
                  maxRating: 5,
                  itemSize: itemSize,
                  itemPadding: EdgeInsets.only(right: spacing),
                  onRatingUpdate: (rating) {
                    state.didChange(rating.toInt());
                    onChanged?.call(rating.toInt());
                  },
                  ratingWidget: RatingWidget(
                    full: Icon(CupertinoIcons.star_fill, color: activeColor),
                    half: Icon(Icons.star, color: inactiveColor ?? Colors.grey),
                    empty: Icon(CupertinoIcons.star_fill, color: inactiveColor ?? Colors.grey[200]),
                  ),
                  allowHalfRating: false,
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 5),
                    child: Text(
                      state.errorText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12.0),
                    ),
                  ),
              ],
            );
          },
        );
}
