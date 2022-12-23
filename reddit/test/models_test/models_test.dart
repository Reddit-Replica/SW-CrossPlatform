import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:reddit/data/home/drawer_communities_model.dart';
import 'package:reddit/data/saved/saved_comments_model.dart';
import 'package:reddit/data/search/search_result_profile_model.dart';

void main() {
  group('models test', () {
    test('drawer model test', () {
      final data = {
        'title': 'sarsora',
        'picture': 'string',
        'members': 0,
        'isFavorite': true
      };

      final DrawerCommunitiesModel model =
          DrawerCommunitiesModel.fromJson(data);

      expect(model.title, 'sarsora');
      expect(model.members, 0);
      expect(model.picture, 'string');
      expect(model.isFavorite, true);
      Map<String, dynamic> m = model.toJson();

      expect(m, data);
    });
    test('search result profile test', () {
      final data = {
        'id': '13245678',
        'data': {
          'id': 'string',
          'username': 'string',
          'karma': 0,
          'nsfw': true,
          'joinDate': '2019-08-24T14:15:22Z',
          'following': true,
          'avatar': 'avatar'
        }
      };

      final SearchResultProfileModel model =
          SearchResultProfileModel.fromJson(data);

      expect(model.id, '13245678');
      expect(model.data?.avatar, 'avatar');
      expect(model.data?.username, 'string');
      expect(model.data?.karma, 0);
      expect(model.data?.nsfw, true);
      expect(model.data?.joinDate, '2019-08-24T14:15:22Z');
      expect(model.data?.following, true);

      Map<String, dynamic> m = model.toJson();

      expect(m, data);
    });
    test('saved comments profile test', () {
      final data = {
        'commentId': '13245678',
        'commentedBy': 'string',
        'points': 0,
        'publishTime': '2019-08-24T14:15:22Z',
       
        'saved': true,
        'inYourSubreddit': true,
      };

      final SavedCommentModel model = SavedCommentModel.fromJson(data);

      expect(model.commentId, '13245678');
      expect(model.commentedBy, 'string');
      expect(model.points, 0);
      expect(model.publishTime, '2019-08-24T14:15:22Z');
      expect(model.inYourSubreddit, true);
      expect(model.saved, true);


    });
  });
}