/// this file is used to define function used as helpers in building the posts.
/// date: 20/12/2022
/// @Author: Ahmed Atta

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:logger/logger.dart';
import '../components/helpers/enums.dart';
import '../components/snack_bar.dart';
import '../cubit/user_profile/cubit/user_profile_cubit.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../components/bottom_sheet.dart';
import '../components/helpers/color_manager.dart';
import '../cubit/post_notifier/post_notifier_state.dart';
import '../data/comment/comment_model.dart';
import '../data/post_model/post_model.dart';
import '../cubit/post_notifier/post_notifier_cubit.dart';
import '../data/mod_in_post_models/approve_model.dart';
import '../data/mod_in_post_models/lock_model.dart';
import '../data/mod_in_post_models/mark_nsfw_model.dart';
import '../data/mod_in_post_models/mark_spoiler_model.dart';
import '../data/mod_in_post_models/remove_model.dart';
import 'package:dio/dio.dart';
import '../data/mod_in_post_models/unsticky_post_model.dart';
import '../networks/constant_end_points.dart';
import '../networks/dio_helper.dart';
import '../shared/local/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../screens/posts/post_screen_cubit/post_screen_cubit.dart';
import '../widgets/posts/actions_cubit/post_comment_actions_cubit.dart';
import '../widgets/posts/actions_cubit/post_comment_actions_state.dart';
import '../widgets/posts/dropdown_list.dart';

/// opens the dropdown menu from the dots in many places
/// [post] is the post that the dropdown menu is opened for
BlocBuilder<PostNotifierCubit, PostNotifierState> dropDownDots(PostModel post) {
  return BlocBuilder<PostNotifierCubit, PostNotifierState>(
    builder: (context, state) {
      return DropDownList(
        post: post,
        itemClass: ItemsClass.posts,
      );
    },
  );
}

/// gets the plain text from the body of a [Document] object
String getPlainText(Map<String, dynamic>? body) {
  Document doc;
  try {
    doc = Document.fromJson((body ?? {'ops': []})['ops']);
  } catch (e) {
    doc = Document();
  }
  return doc.toPlainText();
}

/// builds the [CircleAvatar] for the user's profile picture
CircleAvatar subredditAvatar({small = false, required String imageUrl}) {
  return CircleAvatar(
    radius: small ? min(2.w, 15) : min(5.5.w, 30),
    backgroundImage: NetworkImage(
      '$baseUrl/$imageUrl',
    ),
    onBackgroundImageError: (exception, stackTrace) {},
  );
}

/// builds the row that contains the control of comments sorting
Widget commentSortRow(BuildContext context) {
// a row with a button to choose the sorting type and an icon button for MOD
// operations
  return BlocBuilder<PostAndCommentActionsCubit, PostActionsState>(
    builder: (context, state) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              await modalBottomSheet(
                context: context,
                selectedItem: PostScreenCubit.get(context).selectedItem,
                text: PostScreenCubit.labels,
                title: 'SORT COMMENTS BY',
                selectedIcons: PostScreenCubit.icons,
                unselectedIcons: PostScreenCubit.icons,
              ).then((value) {
                PostScreenCubit.get(context).changeSortType(value);
              });
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
            ),
            icon: Icon(
              PostScreenCubit.get(context).getSelectedIcon(),
              color: ColorManager.greyColor,
            ),
            label: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  PostScreenCubit.get(context).selectedItem,
                  style: const TextStyle(
                    color: ColorManager.greyColor,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: ColorManager.greyColor,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (PostScreenCubit.get(context).post.inYourSubreddit ?? false)
            Material(
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              shape: const CircleBorder(),
              child: BlocBuilder<PostAndCommentActionsCubit, PostActionsState>(
                builder: (context, state) {
                  var cubit = PostAndCommentActionsCubit.get(context);
                  return IconButton(
                    onPressed: () {
                      cubit.toggleModTools();
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(0),
                    icon: Icon(
                      cubit.showModTools ? Icons.shield : Icons.shield_outlined,
                      color: ColorManager.greyColor,
                    ),
                    iconSize: min(6.w, 30),
                  );
                },
              ),
            ),
        ],
      );
    },
  );
}

/// builds the row that contains the avatar of the user, the name of the user,
Widget singleRow(
  context, {
  bool sub = false,
  bool showIcon = false,
  bool showDots = true,
  required bool isWeb,
  required PostModel post,
}) {
  return Row(
    children: [
      if (showIcon)
        subredditAvatar(
            small: true,
            imageUrl:
                PostAndCommentActionsCubit.get(context).subreddit?.picture ??
                    PostAndCommentActionsCubit.get(context).user?.picture ??
                    ''),
      if (showIcon)
        SizedBox(
          width: min(5.w, 0.2.dp),
        ),
      InkWell(
        onTap: () {
          // print('Hello Hello Hello Hello ');
          UserProfileCubit.get(context)
              .showPopupUserWidget(context, post.postedBy!);
        },
        child: Text(
          '${sub ? 'r' : 'u'}/${post.postedBy} • ',
          style: const TextStyle(
            color: ColorManager.greyColor,
            fontSize: 15,
          ),
        ),
      ),
      Text(
        timeago.format(DateTime.tryParse(post.postedAt ?? '') ?? DateTime.now(),
            locale: 'en_short'),
        style: const TextStyle(
          color: ColorManager.greyColor,
          fontSize: 15,
        ),
      ),
      if (showIcon) const Spacer(),
      if (showDots && !isWeb) dropDownDots(post)
    ],
  );
}

/// builds a card for a single Mod Item
Widget buildModItem(icon, text, {bool disabled = false}) {
  return Row(
    children: [
      Icon(icon,
          color: disabled
              ? ColorManager.disabledButtonGrey
              : ColorManager.eggshellWhite,
          size: 22),
      const SizedBox(
        width: 10,
      ),
      Text(
        text,
        style: TextStyle(
            color: disabled
                ? ColorManager.disabledButtonGrey
                : ColorManager.eggshellWhite,
            fontSize: 15),
      ),
    ],
  );
}

/// whether the [post] is approved or not
bool isApproved(PostModel post) {
  if (post.moderation?.approve?.approvedBy == null) {
    return false;
  }
  return true;
}

/// whether the [post] is spammed or not
bool isSpammed(PostModel post) {
  return (post.moderation?.spam?.spammedBy != null);
}

/// whether the [post] is removed or not
bool isRemoved(PostModel post) {
  return (post.moderation?.remove?.removedBy != null);
}

/// handles the spoiler button on the post for moderators
/// if the post is already marked as spoiler, it will unmark it
/// otherwise it will mark it as spoiler
/// [onSuccess] is called when the request is successful
/// [onError] is called when the request fails
/// [post] is the post that is being marked as spoiler

void handleSpoiler(
    {required VoidCallback onSuccess, required VoidCallback onError, post}) {
  final spoilerObj = MarkSpoilerModel(id: post.id);
  String? token = CacheHelper.getData(key: 'token');

  String finalPath = post.spoiler ?? false ? unmarkSpoiler : markSpoiler;

  DioHelper.patchData(token: token, path: finalPath, data: spoilerObj.toJson())
      .then((value) {
    if (value.statusCode == 200) {
      onSuccess();
    }
  }).catchError((err) {
    err as DioError;
    onError();
  });
}

/// handles the nsfw button on the post for moderators
/// [onSuccess] is called when the request is successful
/// [onError] is called when the request fails
/// [post] is the post that is being marked as spoiler
void handleNSFW(
    {required VoidCallback onSuccess, required VoidCallback onError, post}) {
  // marks the post as nsfw
  final nsfwObj = MarkNSFWModel(id: post.id);
  String? token = CacheHelper.getData(key: 'token');

  //check whether post is marked or unmarked as nsfw
  String finalPath = post.nsfw ?? false ? unmarkNSFW : markNSFW;

  DioHelper.patchData(token: token, path: finalPath, data: nsfwObj.toJson())
      .then((value) {
    if (value.statusCode == 200) {
      onSuccess();
    }
  }).catchError((err) {
    onError();
  });
}

/// handles the lock button on the post or comment for moderators
/// if the post is already locked, it will unlock it
/// otherwise it will lock it
/// [onSuccess] is called when the request is successful
/// [onError] is called when the request fails
/// [post] is the post that is being locked
/// [comment] is the comment that is being locked
void handleLock(
    {required VoidCallback onSuccess,
    required VoidCallback onError,
    PostModel? post,
    CommentModel? comment,
    bool isPost = true}) {
  dynamic obj = isPost ? post : comment;
  final lockComments = LockModel(id: obj.id, type: isPost ? 'post' : 'comment');
  String finalPath = obj.moderation?.lock ?? false ? unlock : lock;

  DioHelper.postData(path: finalPath, data: lockComments.toJson())
      .then((value) {
    if (value.statusCode == 200) {
      if (isPost) {
        obj.moderation!.lock = !(obj.moderation!.lock ?? true);
      } else {
        obj.locked = !(obj.locked ?? true);
      }
      onSuccess();
    }
  }).catchError((err) {
    onError();
  });
}

/// handles the sticky button on the post for moderators
/// if the post is already sticky, it will unsticky it
/// otherwise it will sticky it
/// [onSuccess] is called when the request is successful
/// [onError] is called when the request fails
/// [post] is the post that is being stickied
void handleSticky(
    {required VoidCallback onSuccess,
    required VoidCallback onError,
    required PostModel post}) {
  //bool pin = !post.sticky
  final stickUnstickPost = PinPostModel(id: post.id, pin: false);

  DioHelper.postData(path: pinPost, data: stickUnstickPost.toJson())
      .then((value) {
    if (value.statusCode == 200) {
      onSuccess();
    }
  }).catchError((err) {
    onError();
  });
}

/// handles the remove button on the post for moderators
/// if the post is already removed, it will unremove it
/// otherwise it will remove it
/// [onSuccess] is called when the request is successful
/// [onError] is called when the request fails
/// [post] is the post that is being removed
void handleRemove(
    {required VoidCallback onSuccess,
    required void Function(DioError) onError,
    required PostModel post}) {
  final removePost = RemoveModel(id: post.id, type: 'post');
  DioHelper.postData(path: remove, data: removePost.toJson()).then((value) {
    if (value.statusCode == 200) {
      post.moderation?.remove?.removedBy = CacheHelper.getData(key: 'username');
      post.moderation?.approve?.approvedBy = null;
      post.moderation?.spam?.spammedBy = null;
      onSuccess();
    }
  }).catchError((err) {
    onError(err as DioError);
  });
}

/// handles the Approve button on the post or comments for moderators
/// if the post is already approved, it will unapprove it
/// otherwise it will approve it
/// [onSuccess] is called when the request is successful
/// [onError] is called when the request fails
/// [post] is the post that is being approved
/// [comment] is the comment that is being approved
void handleApprove({
  required VoidCallback onSuccess,
  required void Function(DioError) onError,
  required PostModel post,
  bool isPost = true,
  CommentModel? comment,
}) {
  final approvePost = ApproveModel(id: post.id, type: 'post');
  DioHelper.postData(path: approve, data: approvePost.toJson()).then((value) {
    if (isPost) {
      post.moderation?.approve?.approvedBy =
          CacheHelper.getData(key: 'username');
      post.moderation?.spam?.spammedBy = null;
      post.moderation?.remove?.removedBy = null;
    }
    onSuccess();
    // }
  }).catchError((err) {
    err = err as DioError;
    Logger().e(err.response?.data);
    onError(err);
  });
}

/// handles the spam button on the post or comments for moderators
/// if the post is already spammed, it will unspam it
/// otherwise it will spam it
/// [onSuccess] is called when the request is successful
/// [onError] is called when the request fails
/// [post] is the post that is being spammed
/// [comment] is the comment that is being spammed
void handleSpam({
  required VoidCallback onSuccess,
  required void Function(DioError) onError,
  required PostModel post,
  bool isPost = true,
  CommentModel? comment,
}) {
  final approvePost = ApproveModel(id: post.id, type: 'post');
  DioHelper.postData(path: '/mod-spam', data: approvePost.toJson())
      .then((value) {
    if (isPost) {
      post.moderation?.spam?.spammedBy = CacheHelper.getData(key: 'username');
      post.moderation?.approve?.approvedBy = null;
      post.moderation?.remove?.removedBy = null;
    }

    onSuccess();
  }).catchError((err) {
    err = err as DioError;
    Logger().e(err.response?.data);
    onError(err);
  });
}

/// opens a dialog to show the moderator options and proccesses the selected option
/// [context] is the context of the widget
/// [post] is the post that is being moderated
Future<void> showModOperations({
  required BuildContext context,
  required PostModel post,
}) async {
  String message;
  var returnedOption = await showDialog<ModOPtions>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              key: const Key('spoiler-option'),
              onPressed: () {
                Navigator.pop(context, ModOPtions.spoiler);
              },
              child: buildModItem(Icons.privacy_tip_outlined,
                  '${post.spoiler ?? false ? 'Unmark' : 'Mark'}Spoiler'),
            ),
            SimpleDialogOption(
              key: const Key('nsfw-option'),
              onPressed: () {
                Navigator.pop(context, ModOPtions.nsfw);
              },
              child: buildModItem(Icons.eighteen_up_rating,
                  '${post.nsfw ?? false ? 'Unmark' : 'Mark'} NSFW'),
            ),
            SimpleDialogOption(
              key: const Key('lock-option'),
              onPressed: () {
                Navigator.pop(context, ModOPtions.lock);
              },
              child: buildModItem(Icons.lock,
                  '${post.moderation?.lock ?? false ? 'Unlock' : 'Lock'} Comments'),
            ),
            SimpleDialogOption(
              key: const Key('unsticky-option'),
              onPressed: () {
                Navigator.pop(context, ModOPtions.unsticky);
              },
              child: buildModItem(Icons.push_pin_outlined, 'Unsticky Post'),
            ),
            SimpleDialogOption(
              key: const Key('remove-option'),
              onPressed: isRemoved(post)
                  ? null
                  : () {
                      Navigator.pop(context, ModOPtions.remove);
                    },
              child: buildModItem(
                Icons.cancel,
                'Remove Post',
                disabled: isRemoved(post),
              ),
            ),
            SimpleDialogOption(
              key: const Key('spam-option'),
              onPressed: isSpammed(post)
                  ? null
                  : () {
                      Navigator.pop(context, ModOPtions.spam);
                    },
              child: buildModItem(Icons.delete, 'Remove as Spam',
                  disabled: isSpammed(post)),
            ),
            SimpleDialogOption(
              key: const Key('approve-option'),
              onPressed: isApproved(post)
                  ? null
                  : () {
                      Navigator.pop(context, ModOPtions.approve);
                    },
              child: buildModItem(
                  Icons.check, 'Approve${isApproved(post) ? 'd' : ''} Post',
                  disabled: isApproved(post)),
            ),
          ],
        );
      });
  debugPrint(returnedOption.toString());
  switch (returnedOption) {
    case ModOPtions.spoiler:
      //marks or unmarks post as spoiler
      handleSpoiler(
          post: post,
          onSuccess: () {
            // toggle the spoiler in the post
            post.spoiler = !post.spoiler!;
            // snack bar message
            message =
                '${post.spoiler ?? false ? 'post ' 'marked' : 'unmarked'} as spoiler';
            // update the post after any change in the post that modifies the UI
            PostNotifierCubit.get(context).notifyPosts();
          },
          onError: () {
            message =
                'Sorry, please try again later\nError  ${post.spoiler ?? false ? 'marking' : 'unmarking'} as spoiler';
            ScaffoldMessenger.of(context)
                .showSnackBar(responseSnackBar(message: message, error: true));
          });
      break;
    // sends request to mark a post as nsfw
    case ModOPtions.nsfw:
      handleNSFW(
          post: post,
          onSuccess: () {
            // togle the spoiler in the post
            post.nsfw = !post.nsfw!;
            //NOTE -  You have to update the POSTS after any change in the post that modifies the UI
            PostNotifierCubit.get(context).notifyPosts();
          },
          onError: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: ColorManager.red,
                content: Text(
                    'Sorry, please try again later\nError ${post.nsfw ?? false ? 'marking' : 'unmarking'} as NSFW')));
          });
      break;
    case ModOPtions.lock:
      // locks comments on a post so no one can comment
      handleLock(
          post: post,
          onSuccess: () {
            //update the posts after any change in the post that modifies the UI
            PostNotifierCubit.get(context).notifyPosts();
          },
          onError: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Sorry, please try again later\nError ${post.moderation?.lock ?? false ? 'locking' : 'unlocking'} comments')));
          });
      break;

    case ModOPtions.unsticky:
      // pins or unpins a post to or from a subreddit
      handleSticky(
          post: post,
          onSuccess: () {
            // post.pin = !post.pin
            // update the POSTS after any change in the post that modifies the U
            PostNotifierCubit.get(context).notifyPosts();
          },
          onError: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Sorry, please try again later\nError')));
          });
      break;
    case ModOPtions.remove:
      // removes a post from subreddit
      handleRemove(
          onSuccess: () {
            PostNotifierCubit.get(context).notifyPosts();
            ScaffoldMessenger.of(context).showSnackBar(responseSnackBar(
              message: 'Post Removed As Admin',
              error: false,
            ));
          },
          onError: (err) {
            PostNotifierCubit.get(context).notifyPosts();
            ScaffoldMessenger.of(context).showSnackBar(responseSnackBar(
              message: err.response?.data['error'] ?? 'Something went wrong',
              error: false,
            ));
          },
          post: post);
      break;
    case ModOPtions.spam:
      // removes post or comment as spam
      handleSpam(
          onSuccess: () {
            PostNotifierCubit.get(context).notifyPosts();
            ScaffoldMessenger.of(context).showSnackBar(responseSnackBar(
              message: 'Post Marked Spam',
              error: false,
            ));
          },
          onError: (err) {
            PostNotifierCubit.get(context).notifyPosts();
            ScaffoldMessenger.of(context).showSnackBar(responseSnackBar(
              message: err.response?.data['error'] ?? 'Something went wrong',
              error: false,
            ));
          },
          post: post);
      break;
    case ModOPtions.approve:
      // approves a post to be posted in a subreddit
      handleApprove(
          post: post,
          onSuccess: () {
            //mark post moderation as approved
            //update post after any change in the post that modifies the UI
            PostNotifierCubit.get(context).notifyPosts();
          },
          onError: (err) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Sorry, please try again later\nError approving post')));
          });
      break;
    case null:
      break;
  }
}
