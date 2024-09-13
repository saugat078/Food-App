import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_rider_app/Auth/login.dart';
import 'package:grocery_rider_app/consts/constss.dart';
import 'package:grocery_rider_app/consts/firebase_const.dart';
import 'package:grocery_rider_app/services/global_methods.dart';
import 'package:grocery_rider_app/services/utils.dart';
import 'package:grocery_rider_app/widgets/back_widget.dart';
import 'package:grocery_rider_app/loading_manager.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/text_widget.dart';

class ForgetPasswordScreen extends StatefulWidget {
  static const routeName = '/ForgetPasswordScreen';
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailTextController = TextEditingController();
  // bool _isLoading = false;
  @override
  void dispose() {
    _emailTextController.dispose();

    super.dispose();
  }

  bool _isLoading = false;
  void _forgetPassFCT() async {
  final userDoc = await FirebaseFirestore.instance.collection('riders').doc(uid).get();
  final currentEmail = userDoc.data()?['email'];
  print(currentEmail);

  if (_emailTextController.text.isEmpty || !_emailTextController.text.contains("@")) {
    GlobalMethods.errorDialog(
      subtitle: 'Please enter a correct email address',
      context: context,
    );
  } else if (currentEmail != _emailTextController.text) {
    GlobalMethods.errorDialog(
      subtitle: 'The email address does not match the one in the records.\nPlease use the email you used to sign in first.',
      context: context,
    );
  } else {
    setState(() {
      _isLoading = true;
    });
    try {
      await authInstance.sendPasswordResetEmail(email: _emailTextController.text.toLowerCase());
      GlobalMethods.successDialog(
        subtitle: "An email has been sent to your email address",
        context: context,
      );
      await Future.delayed(Duration(seconds: 4)); 
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    } on FirebaseException catch (error) {
      GlobalMethods.errorDialog(
        subtitle: '${error.message}', 
        context: context,
      );
    } catch (error) {
      GlobalMethods.errorDialog(
        subtitle: '$error', 
        context: context,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    return Scaffold(
      // backgroundColor: Colors.blue,
      body: LoadingManager(
        isLoading: _isLoading,
        child: Stack(
          children: [
            Swiper(
              itemBuilder: (BuildContext context, int index) {
                return Image.asset(
                  Constss.authImagesPaths[index],
                  fit: BoxFit.cover,
                );
              },
              autoplay: true,
              itemCount: Constss.authImagesPaths.length,

              // control: const SwiperControl(),
            ),
            Container(
              color: Colors.black.withOpacity(0.7),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.1,
                  ),
                  const BackWidget(),
                  const SizedBox(
                    height: 20,
                  ),
                  TextWidget(
                    text: 'Forget password',
                    color: Colors.white,
                    textSize: 30,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: _emailTextController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Email address',
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  AuthButton(
                    buttonText: 'Reset now',
                    fct: () {
                      _forgetPassFCT();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
