import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:meta/meta.dart';
import 'package:reddit/widgets/user_profile/user_profile_web.dart';
import '../../../components/button.dart';
import '../../../components/helpers/color_manager.dart';
import '../../../components/snack_bar.dart';
import '../../../data/comment/comment_model.dart';
import '../../../data/settings/settings_models/user_settings.dart';
import '../../../data/user_profile/about_user_model.dart';
import '../../../networks/dio_helper.dart';
import '../../../screens/user_profile/user_profile_screen.dart';

import '../../../constants/constants.dart';
import '../../../data/post_model/post_model.dart';
import '../../../networks/constant_end_points.dart';
import '../../../screens/moderation/user_management_screens/invite_moderator.dart';
import '../../../screens/moderation/user_management_screens/moderators.dart';
import '../../../shared/local/shared_preferences.dart';

import 'package:http_parser/src/media_type.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit() : super(UserProfileInitial());
  static UserProfileCubit get(context) => BlocProvider.of(context);
  AboutUserModel? userData;
  String? username;

  XFile? img;

  late PagingController<String?, PostModel> postController;
  late PagingController<String?, Map<String, dynamic>> commentController;

  Future<void> fetchUserData(String userName, {bool navigate = true}) async {
    await DioHelper.getData(
        path: '/user/$userName/about',
        query: {'username': userName}).then((value) {
      if (value.statusCode == 200) {
        username = userName;
        userData = AboutUserModel.fromJson(value.data);
        print('All Done');
        print(userData!.displayName);
        if (userData!.displayName == null || userData!.displayName == '') {
          userData!.displayName = username;
        }
        if (navigate) {
          if (kIsWeb) {
            navigatorKey.currentState!.pushNamed(UserProfileWeb.routeName);
          } else {
            navigatorKey.currentState!.pushNamed(UserProfileScreen.routeName);
          }
        }
        // return true;
      }
    }).catchError((error) {
      print('Error in fetch user data ==> $error');
    });
  }

  void setUsername(String usernamePass, {bool navigate = true}) {
    print('User Name : $usernamePass');
    print(token);
    fetchUserData(usernamePass);
  }

  void fetchPosts({String? after}) {
    final query = {'after': after, 'username': username};
    print('URL : /user/$username/posts');
    print(query);
    print(token);
    DioHelper.getData(path: '/user/$username/posts', query: query)
        .then((value) {
      if (value.statusCode == 200) {
        List<PostModel> fetchedPosts = [];
        for (int i = 0; i < value.data['children'].length; i++) {
          // logger.wtf(i);
          final post = (PostModel.fromJsonwithData(value.data['children'][i]));
          fetchedPosts.add(post);
          print(i);
          print(post.title);
          print(post.id);
        }
        print(value.data['after'] as String);
        if (value.data['after'] as String == '') {
          postController.appendLastPage(fetchedPosts);
        } else {
          postController.appendPage(
              fetchedPosts, value.data['after'] as String);
        }
      }
    }).catchError((error) {
      print('Error In Fetch Posts ==> $error');
    });
  }

  void fetchComments({String? after}) {
    final query = {'after': after, 'username': username};
    print('URL : /user/$username/comments');
    print(query);
    DioHelper.getData(path: '/user/$username/comments', query: query)
        .then((value) {
      if (value.statusCode == 200) {
        List<Map<String, dynamic>> fetchedPosts = [];
        for (int i = 0; i < value.data['children'].length; i++) {
          // logger.wtf(i);
          final post =
              (PostModel.fromJson(value.data['children'][i]['data']['post']));
          // post.id = value.data['children'][i]['id'];
          post.id = value.data['children'][i]['id'];
          print(post.id);
          for (int j = 0;
              j < value.data['children'][i]['data']['comments'].length;
              j++) {
            final comment = (CommentModel.fromJson(
                value.data['children'][i]['data']['comments'][j]));

            print('Post ID : ${post.id}');
            print('Comment ID : ${comment.id}');
            var item = {
              'post': post,
              'comment': comment,
            };
            fetchedPosts.add(item);
          }

          // // fetchedPosts.add(post);
          // var data = {
          //   'post': post,
          //   'comment': comment,
          // };
          // fetchedPosts.add(data);
          // print(i);
          // print(post.title);
        }
        print(value.data['after'] as String);
        if (value.data['after'] as String == '') {
          commentController.appendLastPage(fetchedPosts);
        } else {
          commentController.appendPage(
              fetchedPosts, value.data['after'] as String);
        }
      }
    }).catchError((error) {
      print('Error In Fetch comments ==> $error');
    });
  }

  followOrUnfollowUser(bool follow) {
    print('Follow $follow');
    DioHelper.postData(
        path: followUser,
        data: {'username': username, 'follow': follow}).then((value) {
      if (value.statusCode == 200) {
        print('Success');
        userData!.followed = !(userData!.followed!);
        emit(FollowOrUnfollowState());
      }
    }).catchError((error) {
      print(error);
    });
  }

  showPopupUserWidget(BuildContext context, String userName) async {
    await fetchUserData(userName, navigate: false);
    showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    (userData!.picture == null || userData!.picture == '')
                        ? const AssetImage('assets/images/Logo.png')
                            as ImageProvider
                        : NetworkImage(
                            '$baseUrl/${userData!.picture!}',
                            // fit: BoxFit.cover,
                          ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'u/${userData!.displayName ?? userName}',
                style: const TextStyle(fontSize: 16),
              ),
              ListTile(
                title: Text(
                  '${userData!.karma}',
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: const Text('Karma'),
              ),
              TextButton(
                  onPressed: () {
                    if (kIsWeb) {
                      navigatorKey.currentState!
                          .pushNamed(UserProfileWeb.routeName);
                    } else {
                      navigatorKey.currentState!
                          .pushNamed(UserProfileScreen.routeName);
                    }
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.person),
                      Text('  View profile')
                    ],
                  )),
              if (username != CacheHelper.getData(key: 'username'))
                TextButton(
                    onPressed: () {
                      blockUser(context);
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.block_flipped),
                        Text('  Block Account')
                      ],
                    )),
              // TextButton(
              //     onPressed: () {
              //       Navigator.of(context).push(MaterialPageRoute(
              //           builder: ((context) => const Moderators())));
              //     },
              //     child: Row(
              //       children: const [
              //         Icon(Icons.mail_outline_outlined),
              //         Text('  Invite to Community')
              //       ],
              //     )),
            ]),
          );
        }));
  }

  void blockUser(BuildContext context) {
    showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Block u/${userData!.displayName}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(
                    height: 7,
                  ),
                  const Text(
                    'They won\'t be able to contact you or view your profile, posts, or commentst',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Button(
                        buttonHeight: 30,
                        buttonWidth: MediaQuery.of(context).size.width * 0.35,
                        onPressed: () async {
                          await DioHelper.postData(
                            path: '/block-user',
                            data: {
                              'block': true,
                              'username': username,
                            },
                          ).then((value) {
                            print('Blocked');
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                                responseSnackBar(
                                    message:
                                        'The author of this post has been blocked',
                                    error: false));
                          }).catchError((error) {
                            error = error as DioError;
                            ScaffoldMessenger.of(context).showSnackBar(
                                responseSnackBar(
                                    message: 'An Error', error: true));
                          });
                        },
                        text: 'Block account',
                        backgroundColor: ColorManager.red,
                        splashColor: const Color.fromARGB(100, 0, 0, 0),
                        textColor: ColorManager.white,
                      ),
                      Button(
                        buttonHeight: 30,
                        buttonWidth: MediaQuery.of(context).size.width * 0.25,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        text: 'Cancel',
                        backgroundColor: Colors.transparent,
                        splashColor: const Color.fromARGB(100, 0, 0, 0),
                        textColor: ColorManager.eggshellWhite,
                      ),
                    ],
                  )
                ],
              ),
            )));
  }

  void changeUserProfileInfo(
      BuildContext context, String displayName, String aboutYou, XFile? img) {
    Map<String, String> data = {};
    if (userData!.displayName != displayName) {
      data['displayName'] = displayName;
    }
    if (userData!.about != aboutYou) {
      data['about'] = aboutYou;
    }
    if (img != null) {
      changeProfileBanner(context, img);
    }
    if (data.isNotEmpty) {
      DioHelper.patchData(
              path: accountSettings,
              data: data,
              token: CacheHelper.getData(key: 'token'))
          .then((value) {
        if (value.statusCode == 200) {
          userData!.displayName = displayName;
          userData!.about = aboutYou;
          emit(ChangeUserProfileInfo());
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              responseSnackBar(message: 'Update Successfully', error: false));
        }
      }).catchError((error) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            responseSnackBar(
                message: 'An Error, Please Try Again', error: true));
      });
    }
    Navigator.of(context).pop();
  }

  void addSocialLink(BuildContext context, String text, String url) {
    print({'type': 'custom', 'displayText': text, 'link': url});

    DioHelper.postData(
            path: socialLink,
            data: {'type': 'custom', 'displayText': text, 'link': url})
        .then((value) {
      if (value.statusCode == 201) {
        userData!.socialLinks!
            .add(SocialLink(displayText: text, link: url, type: 'custom'));
        print('Sccess');
        emit(ChangeUserProfileSocialLinks());
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            responseSnackBar(message: 'Add Link Successfully', error: false));
      }
    }).catchError((onError) {
      print('error');

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          responseSnackBar(message: 'An Error, Please Try Again', error: true));
    });
  }

  void deleteSocialLink(
      BuildContext context, String text, String url, int index) {
    print({'type': 'custom', 'displayText': text, 'link': url});
    DioHelper.deleteData(path: socialLink, data: {
      'type': 'custom',
      'displayText': text,
      'link': url,
    }).then((value) {
      if (value.statusCode == 204) {
        userData!.socialLinks!.removeAt(index);
        print('Sccess');
        emit(ChangeUserProfileSocialLinks());
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            responseSnackBar(
                message: 'Link Deleted Successfully', error: false));
      }
    }).catchError((onError) {
      print('error');

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          responseSnackBar(message: 'An Error, Please Try Again', error: true));
    });
  }

  Future<void> changeProfileBanner(BuildContext context, XFile? image) async {
    MultipartFile file = await MultipartFile.fromFile(image!.path,
        filename: image.path.split('/').last,
        contentType: MediaType('image', 'png'));
    print('Change Profile Picture');
    DioHelper.postData(
      isFormdata: true,
      path: userProfileBanner,
      data: FormData.fromMap({'banner': file}),
      sentToken: token,
    ).then((value) {
      if (value.statusCode == 200) {
        print('success Profile Picture');
        emit(ChangeUserProfileBanner());

        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            responseSnackBar(
                message: 'Banner Uploaded Successfully', error: false));
        setUsername(username!, navigate: false);
        img = null;
      }
    }).catchError(
      (error) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            responseSnackBar(message: 'Error When Upload Banner', error: true));
      },
    );
  }

  void deleteBannerImage() {
    DioHelper.deleteData(path: userProfileBanner).then((value) {
      if (value.statusCode == 204) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            responseSnackBar(
                message: 'Banner Deleted Successfully', error: false));
        img = null;
        emit(ChangeUserProfileBanner());
      }
    }).catchError((error) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          responseSnackBar(message: 'Error When Delete Banner', error: true));
    });
  }
}
