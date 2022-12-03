/// @author yasmineghanem
/// @date: 25/10/2022
/// Reuasable custom button component
import 'package:flutter/material.dart';
import 'package:reddit/components/helpers/color_manager.dart';
import 'package:reddit/shared/local/shared_preferences.dart';

class Button extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color backgroundColor;
  final Color? splashColor;
  final double? buttonWidth;
  final double? buttonHeight;
  final FontWeight textFontWeight;
  final double? textFontSize;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;
  final bool disabled;
  final String? imagePath;
  final onPressed;
  bool isPressable = true;

  Button({
    super.key,
    this.text = 'Button',
    this.textColor = ColorManager.white,
    this.backgroundColor = ColorManager.blue,
    this.buttonWidth = 10.0,
    this.buttonHeight = 5.0,
    this.textFontSize = 16,
    this.textFontWeight = FontWeight.normal,
    this.splashColor = ColorManager.white,
    this.borderColor,
    this.borderRadius = 50.0,
    this.borderWidth = 1.0,
    this.disabled = false,
    this.imagePath,
    this.isPressable = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),

          // for circular buttons
          border: Border.all(
            // if border color is not passed set it to background color
            color: borderColor == null ? backgroundColor : borderColor!,
            width: borderColor == null ? 0 : borderWidth,
          )),
      child: MaterialButton(
        onPressed: isPressable ? onPressed : () {},
        minWidth: buttonWidth,
        height: buttonHeight,
        elevation: 0,
        disabledElevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        highlightElevation: 0,
        color: isPressable ? backgroundColor : ColorManager.grey,
        splashColor: (disabled || (CacheHelper.getData(key: 'isWindows')!))
            ? Colors.transparent
            : splashColor,
        highlightColor: (CacheHelper.getData(key: 'isAndroid')!)
            ? Colors.transparent
            : Colors.black.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: imagePath != null
              ? MainAxisAlignment.spaceAround
              : MainAxisAlignment.center,
          children: [
            imagePath == null
                ? const SizedBox(
                    width: 0,
                    height: 0,
                  )
                : SizedBox(
                    height: 25,
                    child: Image.asset(imagePath!, fit: BoxFit.contain)),
            Text(text,
                style: TextStyle(
                    fontSize: textFontSize,
                    fontWeight: textFontWeight,
                    color: textColor)),
          ],
        ),
      ),
    );
  }
}
