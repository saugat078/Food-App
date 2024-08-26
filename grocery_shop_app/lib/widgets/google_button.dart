import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grocery_shop_app/fetch_screen.dart';
import 'package:grocery_shop_app/services/global_methods.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({Key? key}) : super(key: key);

  Future<void> _googleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        if (authResult.additionalUserInfo!.isNewUser) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'name': user.displayName,
            'email': user.email,
            'shipping-address': '',
            'userWish': [],
            'userCart': [],
            'createdAt': Timestamp.now(),
          });
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const FetchScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      GlobalMethods.errorDialog(subtitle: e.message ?? 'An error occurred', context: context);
    } catch (e) {
      GlobalMethods.errorDialog(subtitle: e.toString(), context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue,
      child: InkWell(
        onTap: () => _googleSignIn(context),
        child: Container(
          width: double.infinity,
          height: 50,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              TextWidget(
                text: 'Continue with Google',
                color: Colors.white,
                textSize: 18,
              )
            ],
          ),
        ),
      ),
    );
  }
}