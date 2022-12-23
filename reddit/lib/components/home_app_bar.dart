/// @author Sarah El-Zayat
/// @date 9/11/2022
/// App bar of the application
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reddit/components/bottom_sheet.dart';
import 'package:reddit/components/snack_bar.dart';
import 'package:reddit/constants/constants.dart';
import 'package:reddit/networks/constant_end_points.dart';
import 'package:reddit/networks/dio_helper.dart';
import 'package:reddit/screens/create_community_screen/create_community_screen.dart';
import 'package:reddit/components/app_bar_components.dart';
import 'package:reddit/components/search_field.dart';
import 'package:reddit/screens/inbox/create_message_screen.dart';

import '../cubit/app_cubit/app_cubit.dart';

/// this is a utility function used to mark all the items in the inbox as read
void markAllAsRead(context) async {
  // marking all notifications as read
  await DioHelper.patchData(
          path: markAllNotificationsAsRead, data: {}, token: token)
      .then((response) {
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(responseSnackBar(
          message: 'all notifications has been marked as read 😊',
          error: false));
    }
  }).onError((error, stackTrace) {
    error = error as DioError;
    ScaffoldMessenger.of(context)
        .showSnackBar(responseSnackBar(message: error.message, error: true));
  });

  // marking all post replies as read
  await DioHelper.patchData(
          path: readAllMsgs, data: {'type': 'Post Replies'}, token: token)
      .then((response) {
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(responseSnackBar(
          message: 'all Post Replies has been marked as read 😊',
          error: false));
    }
  }).onError((error, stackTrace) {
    error = error as DioError;
    ScaffoldMessenger.of(context)
        .showSnackBar(responseSnackBar(message: error.message, error: true));
  });

  // marking all messages as read
  await DioHelper.patchData(
          path: readAllMsgs, data: {'type': 'Messages'}, token: token)
      .then((response) {
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(responseSnackBar(
          message: 'all Messages has been marked as read 😊', error: false));
    }
  }).onError((error, stackTrace) {
    error = error as DioError;
    ScaffoldMessenger.of(context)
        .showSnackBar(responseSnackBar(message: error.message, error: true));
  });

  // marking all username mentions as read
  await DioHelper.patchData(
          path: readAllMsgs, data: {'type': 'Username Mentions'}, token: token)
      .then((response) {
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(responseSnackBar(
          message: 'all Username Mentions has been marked as read 😊',
          error: false));
    }
  }).onError((error, stackTrace) {
    error = error as DioError;
    ScaffoldMessenger.of(context)
        .showSnackBar(responseSnackBar(message: error.message, error: true));
  });
}

///@param [index] is the index of the bottom navigation bar screen
///@param [context] is the context of the parent widget
/// returns the app bar of the screen
AppBar homeAppBar(context, index) {
  ///@param [cubit] an instance of the App Cubit to give easier access to the state management cubit
  final AppCubit cubit = AppCubit.get(context);

  ///checks if the it's mobile
  ///depending on the given index the title and actions are changed
  if (!kIsWeb) {
    return AppBar(
      titleSpacing: 0,
      title: cubit.screensNames[index] == 'Home'
          // ? const HomeDropdownMenu()
          ? null
          : cubit.screensNames[index] == 'Discover'
              ? SearchField(textEditingController: TextEditingController())
              : cubit.screensNames[index] == 'Inbox'
                  ? const Text('Inbox')
                  : null,
      actions: [
        cubit.screensNames[index] == 'Home'
            ? IconButton(
                onPressed: () => navigateToSearch(context),
                icon: const Icon(Icons.search))
            : cubit.screensNames[index] == 'Inbox'
                ? IconButton(
                    onPressed: () async {
                      final choice = await modalBottomSheet(
                          context: context,
                          title: 'Manage Notification',
                          text: [
                            'new message',
                            'Mark all inbox tabs as read',
                            'edit notification settings'
                          ],
                          selectedItem: '',
                          selectedIcons: [
                            Icons.edit,
                            Icons.mark_email_read_outlined,
                            Icons.settings,
                          ],
                          unselectedIcons: [
                            Icons.edit,
                            Icons.mark_email_unread,
                            Icons.settings
                          ],
                          items: [
                            'new message',
                            'Mark all inbox tabs as read',
                            'edit notification settings'
                          ]);

                      if (choice == 'new message') {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const CreateMessageScreen();
                        }));
                      } else if (choice == 'Mark all inbox tabs as read') {
                        /// TODO: mark all notifications as read
                        markAllAsRead(context);
                      } else {
                        print(choice);
                      }
                    },
                    icon: const Icon(Icons.more_vert))
                : cubit.screensNames[index] == 'Chat'
                    ? IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.add_comment_outlined))
                    : const Text(''),
        InkWell(
            onTap: () => cubit.changeRightDrawer(),
            child: avatar(context: context))
      ],
    );
  }

  ///if it's web then display the following
  else {
    return AppBar(
      actions: [Container()],
      automaticallyImplyLeading: false,
      title: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            InkWell(
              onTap: () => cubit.changeLeftDrawer(),
              child: Image.asset(
                'assets/images/Reddit_Lockup_OnDark.png',
                scale: 6,
              ),
            ),
            // const HomeDropdownMenu(),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: SearchField(
                  textEditingController: TextEditingController(),
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.chat_outlined),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCommunityScreen(),
                  )),
              icon: const Icon(Icons.add),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            InkWell(
                onTap: () => cubit.changeRightDrawer(),
                child: avatar(context: context))
          ],
        ),
      ),
    );
  }
}
