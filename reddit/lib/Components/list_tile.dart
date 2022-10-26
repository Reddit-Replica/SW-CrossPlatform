/// @author Abdelaziz Salah
/// @date 26/10/2022
/// This is a listTile bluePrint which is
/// built to be a reuseable widget for further uses

import 'package:flutter/material.dart';
import '../Components/color_manager.dart';
import 'enums.dart';

/// this class requires three main parameters
/// 1- [leadingIcon] which is the icon shown in the beginning of the row
/// 2- [title] which is the text shown next to the icon
/// 3- [tailingObj] which may take one of three values
///   3.1- Switch
///   3.2- DropBox
///   3.3- IconButton
// ignore: must_be_immutable
class ListTileWidget extends StatefulWidget {
  final Icon leadingIcon;
  final String title;
  final TrailingObjects tailingObj;
  List<String>? items;

  /// function which should be executed whenever something is changed
  final func;

  ListTileWidget(
      {super.key,
      required this.leadingIcon,
      required this.title,
      required this.func,
      required this.tailingObj,
      this.items});

  @override
  State<ListTileWidget> createState() => _ListTileWidgetState();
}

class _ListTileWidgetState extends State<ListTileWidget> {
  /// this can be either Switch, DropBox or Icon
  String? dropDownValue = 'Empty';
  bool setBool = false;

  /// utility function to build if the tailing object was switch
  Widget buildSwitch(ctx) {
    final mediaQuery = MediaQuery.of(ctx);
    return Container(
      width: mediaQuery.size.width * 0.2,
      height: mediaQuery.size.width * 0.2,
      padding: const EdgeInsets.only(top: 8),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Switch(
          activeColor: ColorManager.blue,
          value: setBool,

          /// TODO: all these onChanged should be changed
          /// when we are doing the settings
          onChanged: (value) {
            setState(() {
              setBool = value;
            });
          },
        ),
      ),
    );
  }

  /// utility function to build if the tailing object was IconButton
  Widget buildIconButton(ctx) {
    final mediaQuery = MediaQuery.of(ctx);
    return SizedBox(
      width: 0.15 * mediaQuery.size.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: IconButton(
          icon: const Icon(
            Icons.arrow_forward,
            color: Colors.grey,
          ),
          onPressed: widget.func,
        ),
      ),
    );
  }

  /// utility function to build if the tailing object was dropDown
  Widget buildDropDown(ctx) {
    final mediaQuery = MediaQuery.of(ctx);
    dropDownValue =
        dropDownValue == 'Empty' ? widget.items?.first : dropDownValue;

    return DropdownButtonHideUnderline(
      child: DropdownButton(
        // Initial Value
        value: dropDownValue,
        dropdownColor: ColorManager.blueGrey,
        // Down Arrow Icon
        icon: const Icon(Icons.keyboard_arrow_down),

        // Array list of items
        items: widget.items?.map((String items) {
          return DropdownMenuItem(
            alignment: Alignment.centerRight,
            value: items,
            child: SizedBox(
                width: mediaQuery.size.width * 0.3,
                height: mediaQuery.size.height * 0.1,
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 14.0 * mediaQuery.textScaleFactor),
                  child: Text(
                    items,
                    style: TextStyle(
                        overflow: TextOverflow.clip,
                        fontSize: 16 * mediaQuery.textScaleFactor,
                        color: Colors.white),
                  ),
                )),
          );
        }).toList(),
        // After selecting the desired option,it will
        // change button value to selected value
        onChanged: (String? newValue) {
          setState(() {
            dropDownValue = newValue!;
          });
        },
      ),
    );
  }

  /// the build main function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListTile(

          /// This is the first el
          leading: widget.leadingIcon,
          title: Text(widget.title),

          /// to set some space between items
          contentPadding: const EdgeInsets.only(left: 10),

          /// min width for the fitst item
          minLeadingWidth: 10,
          trailing: (widget.tailingObj == TrailingObjects.switchButton)
              ? buildSwitch(context)
              : (widget.tailingObj == TrailingObjects.tailingIcon)
                  ? buildIconButton(context)
                  : buildDropDown(context)),
    );
  }
}
