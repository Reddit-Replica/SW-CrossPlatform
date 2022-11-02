import 'package:flutter/material.dart';
import '../../components/default_text_field.dart';
import '../../components/helpers/color_manager.dart';
import '../../widgets/sign_in_and_sign_up_widgets/app_bar.dart';
import '../../components/button.dart';

class RecoverUserName extends StatelessWidget {
  const RecoverUserName({super.key});

  @override
  Widget build(BuildContext context) {
    final customAppBar = LogInAppBar(
        sideBarButtonText: 'Log In',
        sideBarButtonAction: () {
          print('Log in');
        });

    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final textScaleFactor = mediaQuery.textScaleFactor;
    return Scaffold(
      appBar: customAppBar,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(color: ColorManager.darkGrey),
          height: mediaQuery.size.height -
              mediaQuery.padding.top -
              customAppBar.preferredSize.height,
          width: mediaQuery.size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: mediaQuery.size.height * 0.55 -
                    mediaQuery.padding.top -
                    customAppBar.preferredSize.height,
                width: mediaQuery.size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Recover username',
                      style: theme.textTheme.titleMedium,
                    ),
                    const DefaultTextField(labelText: 'Email'),
                    Text(
                      'Unfortunately, if you have never given us your email,'
                      'we will not be able to reset your password.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    SizedBox(
                      child: Column(
                        children: [
                          TextButton(
                              onPressed: () {
                                print('Having trouble');
                              },
                              child: SizedBox(
                                width: mediaQuery.size.width,
                                child: const Text(
                                  'Having trouble?',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: ColorManager.primaryColor),
                                ),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: mediaQuery.size.height * 0.3 -
                    mediaQuery.padding.top -
                    customAppBar.preferredSize.height,
                width: mediaQuery.size.width,
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          print('forget userName');
                        },
                        child: SizedBox(
                          width: mediaQuery.size.width,
                          child: Text(
                            'Forget username?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorManager.eggshellWhite,
                                fontSize: 16.5 * textScaleFactor),
                          ),
                        )),
                    FittedBox(
                      child: Button(
                          text: 'Email me',
                          boarderRadius: 50,
                          textColor: ColorManager.greyColor,
                          backgroundColor: ColorManager.blue,
                          buttonWidth: mediaQuery.size.width,
                          buttonHeight: mediaQuery.size.height * 0.08,
                          textFontSize: 18,
                          onPressed: () {
                            print('Email Me');
                          }),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
