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
      print("Starting Google Sign-In process");
      
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print("Google Sign-In canceled by user");
        return;
      }

      print("Google Sign-In successful. User: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("Got Google Auth. Access Token: ${googleAuth.accessToken != null}, ID Token: ${googleAuth.idToken != null}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Created Firebase credential. Attempting to sign in to Firebase");

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        print("Firebase sign-in successful. User ID: ${user.uid}");

        if (authResult.additionalUserInfo!.isNewUser) {
          print("New user. Creating Firestore document");
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
          print("Firestore document created successfully");
        } else {
          print("Existing user. Skipping Firestore document creation");
        }

        print("Navigating to FetchScreen");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const FetchScreen(),
          ),
        );
      } else {
        print("Firebase sign-in failed. User is null");
        GlobalMethods.errorDialog(subtitle: 'Failed to sign in with Google', context: context);
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      GlobalMethods.errorDialog(subtitle: e.message ?? 'An error occurred', context: context);
    } catch (e) {
      print("Unexpected error: $e");
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