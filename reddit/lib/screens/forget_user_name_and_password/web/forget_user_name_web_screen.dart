/// @author Abdelaziz Salah
/// @date 12/11/2022

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reddit/screens/sign_in_and_sign_up_screen/web/sign_in_for_web_screen.dart';
import 'package:reddit/screens/to_go_screens/having_trouble_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../components/button.dart';
import '../../../components/helpers/color_manager.dart';
import '../../../components/default_text_field.dart';
import '../../../data/sign_in_And_sign_up_models/validators.dart';
import '../../sign_in_and_sign_up_screen/web/sign_up_for_web_screen.dart';

/// this screen is built to show the UI in case that the user is using the app through the web
class ForgetUserNameWebScreen extends StatefulWidget {
  const ForgetUserNameWebScreen({super.key});

  static const routeName = '/forget_username_web_screen_route';

  @override
  State<ForgetUserNameWebScreen> createState() =>
      _ForgetUserNameWebScreenState();
}

class _ForgetUserNameWebScreenState extends State<ForgetUserNameWebScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final navigator = Navigator.of(context);
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // the image box
              SizedBox(
                  // in the website it is fixed not relative
                  width: mediaQuery.size.width > 600 ? 140 : 120,
                  height: 100.h,
                  child: Image.asset(
                    'assets/images/WebSideBarBackGroundImage.png',
                    fit: BoxFit.fitHeight,
                  )),

              // the main screen.
              Container(
                margin: const EdgeInsets.only(left: 28),
                height: 100.h,

                // in the website it is fixed
                width: 430,
                child: Column(
                  children: [
                    // the text container
                    Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(top: 260),
                        height: 20.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                height: 44,
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Image.asset('assets/icons/appIcon.png')),
                            Container(
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  'Recover your username',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                            const Text(
                              'Tell us the username and email address associated with your Reddit account, and we’ll send you an email with a link to reset your password. ',
                              style: TextStyle(
                                  height: 1.3,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w200),
                            )
                          ],
                        )),
                    SizedBox(
                      height: 20.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DefaultTextField(
                            key: const Key('EmailTextField'),
                            keyboardType: TextInputType.emailAddress,
                            formController: emailController,
                            labelText: 'Email Address',
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            alignment: Alignment.centerLeft,
                            child: Button(
                                key: const Key('EmailMeButton'),
                                text: 'EMAIL ME',
                                textColor: ColorManager.white,
                                backgroundColor: ColorManager.hoverOrange,
                                buttonWidth: 13.5.w,
                                borderRadius: 5,
                                textFontWeight: FontWeight.bold,
                                buttonHeight: 4.h,
                                textFontSize: 16,
                                onPressed: () {
                                  if ((Validator.validEmailValidator(
                                      emailController.text))) {
                                    debugPrint('valid');
                                  } else {
                                    debugPrint('Invalid');
                                  }
                                }),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(children: [
                                const TextSpan(
                                    text:
                                        'Don\'t have an email or need assistance logging in?',
                                    style: TextStyle(
                                      color: ColorManager.eggshellWhite,
                                      fontSize: 14.5,
                                    )),
                                TextSpan(
                                  text: '  GET HELP',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      navigator
                                          .pushNamed(TroubleScreen.routeName);
                                    },
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorManager.primaryColor,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ]),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                            width: 430,
                            margin: const EdgeInsets.only(top: 10),
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: 'LOG IN .',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        navigator.pushReplacementNamed(
                                            SignInForWebScreen.routeName);
                                      },
                                    style: const TextStyle(
                                      color: ColorManager.primaryColor,
                                      fontSize: 14.5,
                                    )),
                                TextSpan(
                                  text: ' SIGN UP',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      navigator.pushNamed(
                                          SignUpForWebScreen.routeName);
                                    },
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorManager.primaryColor,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ]),
                              textAlign: TextAlign.left,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
