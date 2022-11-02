import 'package:flutter/material.dart';
import 'package:reddit/components/default_text_field.dart';
import '../../components/button.dart';
import '../../components/helpers/color_manager.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final textScaleFactor = mediaQuery.textScaleFactor;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: ColorManager.darkGrey,
        backgroundColor: ColorManager.darkGrey,
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () {},
              child: Text(
                'Log in',
                style: TextStyle(
                    color: ColorManager.greyColor,
                    fontWeight: FontWeight.bold,
                    fontSize: textScaleFactor * 18),
              ))
        ],
        title: SizedBox(
          height: mediaQuery.size.height * 0.04,
          child: Image.asset('assets/images/Logo.png', fit: BoxFit.contain),
        ),
      ),
      backgroundColor: ColorManager.darkGrey,
      body: Container(
        height: mediaQuery.size.height,
        width: mediaQuery.size.width,
        padding: const EdgeInsets.only(top: 30, left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Text(
                textAlign: TextAlign.center,
                'Hello new friend, welcome to Reddit',
                // style: theme.textTheme.titleMedium,
                style: TextStyle(
                  fontSize: textScaleFactor * 24,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.white,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: mediaQuery.size.height * 0.18,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Button(
                        text: 'Continue with Google',
                        textColor: ColorManager.white,
                        backgroundColor: ColorManager.darkGrey,
                        buttonWidth: mediaQuery.size.width * 0.9,
                        buttonHeight: mediaQuery.size.height * 0.05,
                        textFontSize: textScaleFactor * 18,
                        onPressed: () {},
                        boarderRadius: 20,
                        borderColor: ColorManager.white,
                        textFontWeight: FontWeight.bold),
                    Button(
                        text: 'Continue with Facebook',
                        textColor: ColorManager.white,
                        backgroundColor: ColorManager.darkGrey,
                        buttonWidth: mediaQuery.size.width * 0.9,
                        buttonHeight: mediaQuery.size.height * 0.05,
                        textFontSize: textScaleFactor * 18,
                        onPressed: () {},
                        boarderRadius: 20,
                        borderColor: ColorManager.white,
                        textFontWeight: FontWeight.bold),
                    Text(
                      'OR',
                      style: TextStyle(
                        color: ColorManager.greyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: textScaleFactor * 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: const [
                  DefaultTextField(
                    labelText: 'Email',
                  ),
                  DefaultTextField(
                    labelText: 'Username',
                  ),
                  DefaultTextField(
                    labelText: 'Password',
                    keyboardType: TextInputType.visiblePassword,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    textAlign: TextAlign.center,
                    'By continuing, you agree to our '
                    'User Agreement and Privace Policy',
                    style: TextStyle(color: ColorManager.white),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
                    child: Button(
                        text: 'Continue',
                        boarderRadius: 20,
                        borderColor: ColorManager.white,
                        textFontWeight: FontWeight.bold,
                        textColor: ColorManager.white,
                        backgroundColor: ColorManager.blue,
                        buttonWidth: mediaQuery.size.width,
                        buttonHeight: mediaQuery.size.height * 0.05,
                        textFontSize: textScaleFactor * 14,
                        onPressed: () {}),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
