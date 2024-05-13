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
                  onRatingUpdate: (rating) {
                    state.didChange(rating.toInt());
                  },
                  ratingWidget: RatingWidget(
                    full: const Icon(CupertinoIcons.star_fill, color: Colors.amber),
                    half: const Icon(Icons.star, color: Colors.grey),
                    empty: Icon(CupertinoIcons.star_fill, color: Colors.grey[200]),
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
