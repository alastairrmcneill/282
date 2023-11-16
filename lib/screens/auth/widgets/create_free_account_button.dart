import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';

class CreateFreeAccountButton extends StatelessWidget {
  const CreateFreeAccountButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ButtonStyle(
          // backgroundColor:
          //     MaterialStateProperty.all<Color>(const Color.fromRGBO(80, 124, 241, 1)),
          // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationEmailScreen()));
        },
        child: const Text('Create a free account'),
      ),
    );
  }
}
