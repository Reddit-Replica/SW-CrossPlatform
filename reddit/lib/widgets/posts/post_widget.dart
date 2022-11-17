/// The Main Post Widget that shows in the home and other places
/// date: 8/11/2022
/// @Author: Ahmed Atta

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart';
import 'package:reddit/cubit/posts_cubit/posts_cubit.dart';
import 'package:reddit/widgets/posts/cubit/post_cubit.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../cubit/posts_cubit/posts_state.dart';
import 'post_lower_bar.dart';
import 'post_upper_bar.dart';
import '../../widgets/posts/inline_image_viewer.dart';
import '../../widgets/posts/votes_widget.dart';
import '../../components/helpers/color_manager.dart';
import '../../components/helpers/posts/helper_funcs.dart';
import '../../data/post_model/post_model.dart';

/// The widget that displays the post
///
/// it's inteded to be used in the HOME PAGE
class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.post,
    this.outsideScreen = true,
  });

  /// determines if the post is in the home page or in the post screen
  final bool outsideScreen;

  /// the post to show
  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostCubit(post),
      child: ResponsiveBuilder(
        builder: (buildContext, sizingInformation) {
          bool isWeb =
              sizingInformation.deviceScreenType != DeviceScreenType.mobile;
          return Container(
            color: ColorManager.darkGreyBlack,
            // margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWeb)
                  VotesPart(
                    post: post,
                    isWeb: isWeb,
                  ),
                Expanded(
                  child: InkWell(
                    onTap: outsideScreen
                        ? () {
                            goToPost(context, post);
                          }
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // A row with the Avatar, title and the subreddit
                        PostUpperBar(
                          post: post,
                          outSide: outsideScreen,
                        ),
                        // The body of the post
                        if (post.images != null && post.images!.isNotEmpty)
                          InlineImageViewer(
                            post: post,
                          ),

                        if (post.images == null || !outsideScreen)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 5,
                            ),
                            child: Html(
                              data: markdownToHtml(post.content ?? ''),
                              shrinkWrap: true,
                              style: {
                                '#': Style(
                                  color: outsideScreen
                                      ? ColorManager.greyColor
                                      : ColorManager.eggshellWhite,
                                  fontSize: const FontSize(15),
                                  maxLines: outsideScreen ? 3 : null,
                                  textOverflow: outsideScreen
                                      ? TextOverflow.ellipsis
                                      : null,
                                  // margin: EdgeInsets.zero,
                                  padding: EdgeInsets.zero,
                                ),
                              },
                            ),
                          ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isWeb)
                              Expanded(flex: 1, child: VotesPart(post: post)),
                            Expanded(
                              flex: 2,
                              child: PostLowerBarWithoutVotes(
                                  post: post,
                                  isWeb: isWeb,
                                  pad: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 10)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
