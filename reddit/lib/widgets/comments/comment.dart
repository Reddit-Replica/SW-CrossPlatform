import 'dart:math';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/conditional_switch.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import '../../components/helpers/color_manager.dart';
import '../../components/helpers/enums.dart';
import '../../cubit/comment_notifier/comment_notifier_cubit.dart';
import '../../cubit/comment_notifier/comment_notifier_state.dart';
import '../../cubit/post_notifier/post_notifier_cubit.dart';
import '../../cubit/post_notifier/post_notifier_state.dart';
import '../../cubit/user_profile/cubit/user_profile_cubit.dart';
import '../../data/comment/comment_model.dart';
import '../../functions/post_functions.dart';
import '../posts/actions_cubit/post_comment_actions_state.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../screens/comments/add_comment_screen.dart';
import '../../screens/posts/post_screen_cubit/post_screen_cubit.dart';
import '../posts/actions_cubit/post_comment_actions_cubit.dart';
import '../posts/votes_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../components/helpers/universal_ui/universal_ui.dart';
import '../../data/post_model/post_model.dart';
import '../posts/dropdown_list.dart';

class Comment extends StatefulWidget {
  const Comment({
    super.key,
    required this.post,
    required this.comment,
    this.stop = false,
    this.viewType = CommentView.normal,
    this.level = 1,
  });
  final PostModel post;

  final CommentModel comment;

  final bool stop;

  final int level;

  final CommentView viewType;

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();
  QuillController getController() {
    Document doc;
    var content = widget.comment.commentBody;
    try {
      doc = Document.fromJson((content ?? {'ops': []})['ops']);
    } catch (e) {
      doc = Document();
    }

    return QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = getController();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Container();
    }
    Widget quillEditor = MouseRegion(
      cursor: SystemMouseCursors.text,
      child: QuillEditor(
        controller: _controller!,
        scrollController: ScrollController(),
        scrollable: false,
        focusNode: _focusNode,
        autoFocus: false,
        readOnly: true,
        placeholder: '',
        expands: false,
        showCursor: false,
        padding: EdgeInsets.zero,
        embedBuilders: [
          ...FlutterQuillEmbeds.builders(),
        ],
      ),
    );
    if (kIsWeb) {
      quillEditor = MouseRegion(
        cursor: SystemMouseCursors.text,
        child: QuillEditor(
          controller: _controller!,
          scrollController: ScrollController(),
          scrollable: true,
          focusNode: _focusNode,
          autoFocus: false,
          readOnly: false,
          placeholder: 'Add content',
          expands: false,
          padding: EdgeInsets.zero,
          embedBuilders: defaultEmbedBuildersWeb,
        ),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PostAndCommentActionsCubit(
            post: widget.post,
            currentComment: widget.comment,
          )..getUserDetails(),
        ),
      ],
      child: BlocConsumer<CommentNotifierCubit, CommentsNotifierState>(
        listener: (context, state) {
          if (state is CommentsContentChanged) {
            setState(() {
              _controller = getController();
            });
          }
        },
        builder: (context, state) {
          return ConditionalSwitch.single(
            context: context,
            valueBuilder: (BuildContext context) => widget.viewType,
            caseBuilders: {
              CommentView.normal: (BuildContext context) =>
                  _normalComment(quillEditor),
              CommentView.inSearch: (BuildContext context) =>
                  _searchComment(quillEditor),
              CommentView.inSubreddits: (BuildContext context) =>
                  _subComments(),
            },
            fallbackBuilder: (BuildContext context) =>
                _normalComment(quillEditor),
          );
        },
      ),
    );
  }

  Widget _normalComment(quillEditor) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onLongPress: () {
        setState(() {
          widget.comment.isCollapsed = !widget.comment.isCollapsed;
        });
      },
      onTap: () {
        if (widget.comment.isCollapsed) {
          setState(() {
            widget.comment.isCollapsed = !widget.comment.isCollapsed;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: widget.level > 1
                ? const BorderSide(
                    color: ColorManager.lightGrey,
                    width: 3,
                  )
                : BorderSide.none,
          ),
          color: ColorManager.darkGrey,
        ),
        padding: EdgeInsets.only(
          left: 10,
          right: widget.level == 1 ? 10 : 0,
          top: 5,
          bottom: 5,
        ),

        // margin: EdgeInsets.only(left: widget.level * 10.0),
        child: ConditionalBuilder(
          condition: widget.comment.isCollapsed,
          builder: (context) {
            return commentAsRow(
                comment: widget.comment,
                showContent: true,
                content:
                    _controller!.document.toPlainText().replaceAll('\\n', ''));
          },
          fallback: (context) {
            return Column(
              children: [
                commentAsRow(
                  comment: widget.comment,
                  showDots: false,
                ),
                quillEditor,
                // _commentsRow(),

                _commentsControlRow(),
                widget.comment.children != null
                    ? Column(
                        children: widget.comment.children!
                            .map((e) => Comment(
                                  post: widget.post,
                                  comment: e,
                                  level: widget.level + 1,
                                ))
                            .toList(),
                      )
                    : Container(),

                // if there is more children add a button to show them
                if (widget.comment.children != null &&
                    widget.comment.children!.length <
                        (widget.comment.numberofChildren!))
                  InkWell(
                    onTap: () {
                      PostScreenCubit.get(context).showMoreComments(
                        commentId: widget.comment.id!,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: const Text(
                        'Show more comments',
                        style: TextStyle(
                          color: ColorManager.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _commentsControlRow() {
    return BlocBuilder<PostNotifierCubit, PostNotifierState>(
      builder: (context, state) {
        return Row(
          children: [
            const Spacer(),
            DropDownList(
              post: widget.post,
              comment: widget.comment,
              itemClass: ItemsClass.comments,
            ),
            SizedBox(width: 5.w),
            InkWell(
              onTap: () {
                setState(() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddCommentScreen(
                                post: widget.post,
                                parentComment: widget.comment,
                              ))).then((value) {
                    PostScreenCubit.get(context).getCommentsOfPost();
                  });
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    Icons.reply_rounded,
                    color: ColorManager.greyColor,
                    size: min(5.5.w, 30),
                  ),
                  const Text(
                    'Reply',
                    style: TextStyle(
                      color: ColorManager.greyColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            BlocBuilder<PostNotifierCubit, PostNotifierState>(
              builder: (context, state) {
                return VotesPart(post: widget.post);
              },
            ),
          ],
        );
      },
    );
  }

  Widget commentAsRow({
    bool showDots = true,
    bool showContent = false,
    String content = '',
    required CommentModel comment,
  }) {
    return BlocBuilder<PostAndCommentActionsCubit, PostActionsState>(
      builder: (context, state) {
        return InkWell(
          onTap: () {
            UserProfileCubit.get(context).showPopupUserWidget(
              context,
              comment.commentedBy ?? '',
            );
          },
          child: Row(
            children: [
              subredditAvatar(
                  small: true,
                  imageUrl:
                      PostAndCommentActionsCubit.get(context).user?.picture ??
                          ''),
              SizedBox(
                width: min(5.w, 10),
              ),
              Text(
                '${'u'}/${comment.commentedBy} ',
                style: const TextStyle(
                  color: ColorManager.greyColor,
                  fontSize: 15,
                ),
              ),
              Text(
                '• ${timeago.format(DateTime.tryParse(comment.editTime ?? '') ?? DateTime.now(), locale: 'en_short')}',
                style: const TextStyle(
                  color: ColorManager.greyColor,
                  fontSize: 15,
                ),
              ),
              if (showContent)
                Expanded(
                  child: Text(
                    ' • ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ColorManager.greyColor,
                      fontSize: 15,
                    ),
                  ),
                ),
              if (showDots)
                BlocBuilder<PostNotifierCubit, PostNotifierState>(
                  builder: (context, state) {
                    return DropDownList(
                      post: widget.post,
                      comment: widget.comment,
                      itemClass: ItemsClass.comments,
                    );
                  },
                )
            ],
          ),
        );
      },
    );
  }

  Widget _searchComment(quillEditor) {
    return Container(
      color: ColorManager.darkGrey,
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            commentAsRow(
              comment: widget.comment,
              showDots: false,
            ),
            quillEditor,
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${widget.comment.votes ?? 0} points',
                  style: TextStyle(
                    color: ColorManager.lightGrey,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _subComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.title ?? '',
          style: TextStyle(
            color: ColorManager.eggshellWhite,
            fontSize: 16.sp,
          ),
        ),
        Row(
          children: [
            Text(
              'r/${widget.post.subreddit}',
              style: TextStyle(
                color: ColorManager.lightGrey,
                fontSize: 15.sp,
              ),
            ),
            Text(
              ' • ${timeago.format(DateTime.tryParse(widget.post.postedAt ?? '') ?? DateTime.now(), locale: 'en_short')}',
              style: TextStyle(
                color: ColorManager.greyColor,
                fontSize: 15.sp,
              ),
            ),
            Text(
              ' • ${widget.post.votes ?? ''} upvotes',
              style: TextStyle(
                color: ColorManager.lightGrey,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
        Text(
          _controller!.document.toPlainText(),
          style: TextStyle(
            color: ColorManager.eggshellWhite,
            fontSize: 16.sp,
          ),
        )
      ],
    );
  }
}
