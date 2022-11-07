import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart';
import 'package:reddit/posts/inline_image_viewer.dart';
import 'package:flutter_html/flutter_html.dart';
import '../components/helpers/color_manager.dart';
import 'helper_funcs.dart';
import 'post_lower_bar.dart';
import 'post_model/post_model.dart';
import 'post_upper_bar.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.post,
    this.outsideScreen = true,
  });
  final bool outsideScreen;
  final PostModel post;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (buildContext, boxConstraints) {
        return Container(
          color: ColorManager.darkGrey,
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            onTap: outsideScreen
                ? () {
                    goToPost(context, post);
                  }
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A row with the Avatar, title and the subreddit
                PostUpperBar(post: post),
                // The body of the post
                if (post.data!.images != null && post.data!.images!.isNotEmpty)
                  InlineImageViewer(
                    post: post,
                  ),

                if (post.data!.images == null || !outsideScreen)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                      // top: 10,
                    ),
                    child: Html(
                      data: markdownToHtml(post.data!.content ?? ''),
                      shrinkWrap: true,
                      style: {
                        '#': Style(
                          color: outsideScreen
                              ? ColorManager.greyColor
                              : ColorManager.white,
                          fontSize: const FontSize(15),
                          maxLines: outsideScreen ? 3 : null,
                          textOverflow:
                              outsideScreen ? TextOverflow.ellipsis : null,
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                        ),
                      },
                    ),
                  ),

                PostLowerBar(
                    post: post,
                    pad: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 10))
              ],
            ),
          ),
        );
      },
    );
  }
}
