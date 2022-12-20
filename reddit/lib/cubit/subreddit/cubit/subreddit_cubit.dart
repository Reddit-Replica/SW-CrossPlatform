import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:reddit/data/post_model/post_model.dart';
import 'package:reddit/data/subreddit/subreddit_model.dart';
import 'package:reddit/networks/constant_end_points.dart';
import 'package:reddit/networks/dio_helper.dart';
import 'package:reddit/shared/local/shared_preferences.dart';
import '../../../components/snack_bar.dart';
import '../../../data/subreddit/moderators_model.dart';
import '../../../screens/comments/add_comment_screen.dart';
import '../../../screens/subreddit/subreddit_screen.dart';
part 'subreddit_state.dart';

class SubredditCubit extends Cubit<SubredditState> {
  SubredditCubit() : super(SubredditInitial());

  static SubredditCubit get(context) => BlocProvider.of(context);

  SubredditModel? subreddit;
  late String subredditName;
  late ModeratorModel moderators;
  List<PostModel> posts = [];
  late PagingController<String?, PostModel> pagingController;

  int selectedIndex = 0;

  void setSubredditName(BuildContext context, String name) {
    Map<String, String> query = {'subreddit': name};
    DioHelper.getData(path: '$subredditInfo/$name', query: query).then((value) {
      if (value.statusCode == 200) {
        logger.wtf('Subreddit Info ====>');
        logger.wtf(value.data);
        subreddit = SubredditModel.fromJson(value.data);
        subredditName = name;
        if (subreddit!.isMember == null) return;
      }
    }).catchError((error) {
      return;
    });

    DioHelper.getData(path: '/r/$name/about/moderators', query: {
      'subreddit': name,
    }).then((value) {
      if (value.statusCode == 200) {
        moderators = ModeratorModel.fromJson(value.data);
        Navigator.of(context).pushNamed(Subreddit.routeName);
      }
    }).catchError((error) {});
  }

  void leaveCommunity() {
    String token = CacheHelper.getData(key: 'token');
    DioHelper.postData(
        sentToken: token,
        path: leaveSubreddit,
        data: {'subredditName': subredditName}).then((value) {
      if (value.statusCode == 200) {
        subreddit!.isMember = false;
        emit(LeaveSubredditState());
      }
    }).catchError((error) {});
  }

  void joinCommunity() {
    String token = CacheHelper.getData(key: 'token');
    DioHelper.postData(
        sentToken: token,
        path: joinSubreddit,
        data: {'subredditId': subreddit!.subredditId}).then((value) {
      if (value.statusCode == 200) {
        subreddit!.isMember = true;
        emit(JoinSubredditState());
      }
    }).catchError((error) {});
  }

  void fetchPosts({String? after, required String sortBy}) {
    final query = {'after': after, 'subreddit': subredditName};
    DioHelper.getData(path: '/r/$subredditName/$sortBy', query: query)
        .then((value) {
      if (value.statusCode == 200) {
        List<PostModel> fetchedPosts = [];
        for (int i = 0; i < value.data['children'].length; i++) {
          // logger.wtf(i);
          final post = (PostModel.fromJsonwithData(value.data['children'][i]));
          fetchedPosts.add(post);
        }
        if (value.data['after'] as String == '') {
          pagingController.appendLastPage(fetchedPosts);
        } else {
          pagingController.appendPage(
              fetchedPosts, value.data['after'] as String);
        }
      }
    }).catchError((error) {});
  }
}
