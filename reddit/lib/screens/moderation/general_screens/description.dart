import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../components/button.dart';
import '../../../components/default_text_field.dart';
import '../../../components/helpers/color_manager.dart';

class Description extends StatefulWidget {
  static const String routeName = 'description';
  const Description({super.key});

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  final TextEditingController _controller = TextEditingController();
  bool isEmpty = true;
  _enabledButton() {
    //do something
  }

  _onChanged() {
    setState(() {
      isEmpty = _controller.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_back,
                size: 24.sp,
              )),
          backgroundColor: ColorManager.darkGrey,
          title: const Text('Description'),
          actions: [
            Button(
                onPressed: isEmpty
                    ? () {}
                    : () {
                        _enabledButton();
                      },
                text: 'Save',
                textFontSize: 16.sp,
                buttonHeight: 5.h,
                buttonWidth: 20.w,
                textColor: isEmpty
                    ? ColorManager.darkBlue
                    : ColorManager.darkBlueColor,
                backgroundColor: ColorManager.darkGrey,
                splashColor: ColorManager.grey,
                disabled: isEmpty,
                borderRadius: 4.0)
          ]),
      body: Container(
          color: ColorManager.darkGrey,
          padding: const EdgeInsets.all(20),
          child: Center(
              child: DefaultTextField(
            formController: _controller,
            labelText: 'Describe you community',
            maxLength: 500,
            onChanged: (description) {
              _onChanged();
            },
          ))),
    );
  }
}
