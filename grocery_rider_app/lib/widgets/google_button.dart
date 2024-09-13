import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grocery_rider_app/auth/phone.dart';
import 'package:grocery_rider_app/consts/firebase_const.dart';
import 'package:grocery_rider_app/pages/order_list.dart';
import 'package:grocery_rider_app/services/global_methods.dart';
import 'package:grocery_rider_app/widgets/text_widget.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({Key? key}) : super(key: key);

  Future<void> _googleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
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
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': user.email,
            'name': user.displayName,
            'phone': '',
            'id': user.uid,
            'shipping-address': '',
            'userWish': [],
            'userCart': [],
            'createdAt': Timestamp.now(),
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PhoneVerificationScreen(user: user),
            ),
          );
        } else {
          // User already exists, navigate to fetch screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => OrdersList(riderId: uid),
            ),
          );
        }
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