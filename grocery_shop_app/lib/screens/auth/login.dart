import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:grocery_shop_app/consts/constss.dart';
import 'package:grocery_shop_app/consts/firebase_const.dart';
import 'package:grocery_shop_app/fetch_screen.dart';
import 'package:grocery_shop_app/screens/auth/forget_pass.dart';
import 'package:grocery_shop_app/screens/auth/register.dart';
import 'package:grocery_shop_app/screens/loading_manager.dart';
import 'package:grocery_shop_app/services/global_methods.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/google_button.dart';
import '../../widgets/text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/LoginScreen';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailTextController = TextEditingController();
  final _passTextController = TextEditingController();
  final _passFocusNode = FocusNode();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _obscureText = true;
  @override
  void dispose() {
    _emailTextController.dispose();
    _passTextController.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  Future<void> storeFCMToken(String userID) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print("FCM Token is: $token");
  if (token != null) {
    await FirebaseFirestore.instance.collection('users').doc(userID).update({
      'fcmToken': token,
    });
  }
}
  void _submitFormOnLogin() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();

      try {

        await authInstance.signInWithEmailAndPassword(
            email: _emailTextController.text.toLowerCase().trim(),
            password: _passTextController.text.trim());
        await storeFCMToken(authInstance.currentUser!.uid);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const FetchScreen(),
        ));
        print('Succefully logged in');
      } on FirebaseException catch (error) {
        GlobalMethods.errorDialog(
            subtitle: '${error.message}', context: context);
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        GlobalMethods.errorDialog(subtitle: '$error', context: context);
        setState(() {
          _isLoading = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingManager(
        isLoading: _isLoading,
        child: Stack(children: [
          Swiper(
            duration: 800,
            autoplayDelay: 8000,
            itemBuilder: (BuildContext context, int index) {
              return Image.asset(
                Constss.authImagesPaths[index],
                fit: BoxFit.cover,
              );
            },
            autoplay: true,
            itemCount: Constss.authImagesPaths.length,
          ),
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    height: 120.0,
                  ),
                  TextWidget(
                    text: 'Welcome Back',
                    color: Colors.white,
                    textSize: 30,
                    isTitle: true,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextWidget(
                    text: "Sign in to continue",
                    color: Colors.white,
                    textSize: 18,
                    isTitle: false,
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_passFocusNode),
                            controller: _emailTextController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty || !value.contains('@')) {
                                return 'Please enter a valid email address';
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          //Password

                          TextFormField(
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () {
                              _submitFormOnLogin();
                            },
                            controller: _passTextController,
                            focusNode: _passFocusNode,
                            obscureText: _obscureText,
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) {
                              if (value!.isEmpty || value.length < 7) {
                                return 'Please enter a valid password';
                              } else {
                                return null;
                              }
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  child: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  )),
                              hintText: 'Password',
                              hintStyle: const TextStyle(color: Colors.white),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () {
                        GlobalMethods.navigateTo(
                            ctx: context,
                            routeName: ForgetPasswordScreen.routeName);
                      },
                      child: const Text(
                        'Forget password?',
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.normal),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  AuthButton(
                    fct: _submitFormOnLogin,
                    buttonText: 'Login',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const GoogleButton(),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Colors.white,
                          thickness: 2,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      TextWidget(
                        text: 'OR',
                        color: Colors.white,
                        textSize: 18,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Expanded(
                        child: Divider(
                          color: Colors.white,
                          thickness: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AuthButton(
                    fct: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FetchScreen(),
                        ),
                      );
                    },
                    buttonText: 'Continue as a guest',
                    primary: Colors.black,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RichText(
                      text: TextSpan(
                          text: 'Don\'t have an account?',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          children: [
                        TextSpan(
                            text: '  Sign up',
                            style: const TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                GlobalMethods.navigateTo(
                                    ctx: context,
                                    routeName: RegisterScreen.routeName);
                              }),
                      ]))
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
