import 'package:flutter/material.dart';
import 'package:two_eight_two/services/services.dart';

// Custom button for google sign in with shape and method
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(const Color.fromRGBO(80, 124, 241, 1)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        onPressed: () async {
          await AuthService.signInWithGoogle(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 26,
              width: 26,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
              child: Image.asset("assets/images/google_icon.png"),
            ),
            const SizedBox(width: 8),
            const Text('Sign in with Google'),
          ],
        ),
      ),
    );
  }
}
