import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_shop_app/consts/constss.dart';
import 'package:grocery_shop_app/fetch_screen.dart';
import 'package:grocery_shop_app/screens/loading_manager.dart';
import 'package:grocery_shop_app/services/global_methods.dart';
import 'package:grocery_shop_app/services/utils.dart';
import 'package:grocery_shop_app/widgets/auth_button.dart';
import 'package:grocery_shop_app/widgets/back_widget.dart';
import 'package:grocery_shop_app/widgets/text_widget.dart';
class changePhoneScreen extends StatefulWidget {
  static const routeName='/changePhone';
  final User? user;

  const changePhoneScreen({Key? key, required this.user}) : super(key: key);

  @override
  _changePhoneScreenState createState() => _changePhoneScreenState();
}

class _changePhoneScreenState extends State<changePhoneScreen> {
  final _phoneController = TextEditingController(text: '+977 ');
  final _otpController = TextEditingController();
  String _verificationId = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _checkAndSendOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newPhoneNumber = _phoneController.text.trim();
      print(newPhoneNumber);

      if (widget.user == null) {
        GlobalMethods.errorDialog(
          context: context,
          subtitle: 'No user found. Please log in first.',
        );
      } else {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).get();
        final currentPhoneNumber = userDoc.data()?['phone'];
        print(currentPhoneNumber);

        if (currentPhoneNumber == null) {
          GlobalMethods.errorDialog(
            context: context,
            subtitle: 'No phone number found. Please log in first.',
          );
        } else if (currentPhoneNumber == newPhoneNumber) {
          GlobalMethods.errorDialog(
            context: context,
            subtitle: 'This phone number is already in use.',
          );
        } else {
          _sendOTP();
        }
      }
    } catch (e) {
      GlobalMethods.errorDialog(
        subtitle: 'Error checking phone number: ${e.toString()}',
        context: context,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _sendOTP() async {
    setState(() {
      _isLoading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) {
        // await _linkPhoneCredential(credential);
        print("----------------------------verificationCompleted");
      },
      verificationFailed: (FirebaseAuthException e) {
        GlobalMethods.errorDialog(subtitle: e.message ?? 'An error occurred', context: context);
        setState(() {
          _isLoading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      await _linkPhoneCredential(credential);
      await _updatePhoneNumber();
    } on FirebaseAuthException catch (e) {
      GlobalMethods.errorDialog(subtitle: e.message ?? 'An error occurred', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _linkPhoneCredential(PhoneAuthCredential credential) async {
    try {
      await widget.user!.linkWithCredential(credential);
      await _updatePhoneNumber();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const FetchScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      GlobalMethods.errorDialog(subtitle: e.message ?? 'An error occurred', context: context);
    }
  }

  Future<void> _updatePhoneNumber() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).update({
        'phone': _phoneController.text.trim(),
      });
      GlobalMethods.successDialog(context: context, subtitle: 'Phone number updated successfully');
    } catch (e) {
      GlobalMethods.errorDialog(subtitle: 'Error updating phone number: ${e.toString()}', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    return Scaffold(
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
            ),
            Container(
              color: Colors.black.withOpacity(0.7),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.1),
                  const BackWidget(),
                  const SizedBox(height: 20),
                  TextWidget(
                    text: 'Change Phone Number',
                    color: Colors.white,
                    textSize: 30,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: '+977 Phone Number',
                      hintStyle: TextStyle(color: Colors.white54),
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
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      _PhonePrefixFormatter(),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                      LengthLimitingTextInputFormatter(15),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (_verificationId.isNotEmpty)
                    TextField(
                      controller: _otpController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter OTP',
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
                      keyboardType: TextInputType.number,
                    ),
                  const SizedBox(height: 15),
                  AuthButton(
                    buttonText: _verificationId.isEmpty ? 'Send OTP' : 'Verify OTP',
                    fct: _verificationId.isEmpty ? _sendOTP : _verifyOTP,
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
class _PhonePrefixFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < 5) {
      return TextEditingValue(
        text: '+977 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }
    return newValue;
  }
}