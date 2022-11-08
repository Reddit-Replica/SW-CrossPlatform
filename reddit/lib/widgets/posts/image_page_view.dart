import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:reddit/components/helpers/color_manager.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'post_lower_bar.dart';
import '../../Data/post_model/post_model.dart';

/// A widget that displays the images in all the Screen
/// it shows images with the help of [PageView]
/// and [PhotoViewGallery]
class WholeScreenImageViewer extends StatefulWidget {
  /// Creates a widget that displays the images in all the Screen
  ///
  /// [post] and [initialIndex] cann't be null
  WholeScreenImageViewer({
    super.key,
    required this.post,
    this.initialIndex = 0,
    this.backgroundDecoration = const BoxDecoration(
      color: Colors.black,
    ),
  })  : pageController =
            PageController(initialPage: initialIndex, keepPage: true),
        assert(post.images != null),
        assert(initialIndex >= 0);

  /// The initial page to show when first creating the [PhotoViewGallery].
  final int initialIndex;

  /// The controller for the page view.
  final PageController pageController;

  /// The decoration to paint behind the child.
  final BoxDecoration? backgroundDecoration;

  /// The post to show
  final PostModel post;

  @override
  State<WholeScreenImageViewer> createState() => _WholeScreenImageViewerState();
}

class _WholeScreenImageViewerState extends State<WholeScreenImageViewer> {
  late int currentIndex = widget.initialIndex;
  double aspectRatio = 1.0;
  double initialInDragging = 0.0;

  /// called when the page is changed
  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    for (var i = 0; i < widget.post.images!.length; i++) {
      Image(image: NetworkImage(widget.post.images![i]))
          .image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((info, call) {
        setState(() {
          aspectRatio = max(aspectRatio, info.image.height / info.image.width);
          // print(aspectRatio);
        });
      }));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: GestureDetector(
        onVerticalDragStart: (details) {
          initialInDragging = details.globalPosition.dy;
        },
        onVerticalDragUpdate: (details) {
          // double diff = details.globalPosition.dy - diffInDragging;
          // debugPrint('diff:' + diff.toString());
        },
        onVerticalDragEnd: (details) {
          // debugPrint('speed: ' + details.primaryVelocity.toString());
        },
        child: Container(
          decoration: widget.backgroundDecoration,
          // alignment: Alignment.center,
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: [
              PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: _buildItem,
                itemCount: widget.post.images!.length,
                // loadingBuilder: widget.loadingBuilder,
                backgroundDecoration: widget.backgroundDecoration,
                pageController: widget.pageController,
                onPageChanged: onPageChanged,
                scrollDirection: Axis.horizontal,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: PostLowerBarWithoutVotes(
                  post: widget.post,
                  backgroundColor: Colors.black.withOpacity(0.5),
                  iconColor: ColorManager.eggshellWhite,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.5),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'r/${widget.post.subreddit ?? '-'} • ',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
              ),
              InkWell(
                onTap: () {
                  debugPrint('joined');
                },
                child: Text(
                  'Join',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.blue,
                      ),
                ),
              ),
              Text(
                '  •   u/${widget.post.postedBy ?? '-'}  • ',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
              ),
              Text(
                timeago.format(DateTime.parse(widget.post.publishTime!),
                    locale: 'en_short'),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          Text(
            widget.post.title ?? '',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// Builds a single item for the gallery
  ///
  /// [index] is the index of the item
  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final String item = widget.post.images![index];
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(item),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 0.5,
      maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item),
    );
  }
}
