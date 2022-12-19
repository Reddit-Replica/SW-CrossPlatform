import 'dart:convert';
import 'dart:math';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:reddit/components/helpers/color_manager.dart';
import 'package:reddit/cubit/post_notifier/post_notifier_cubit.dart';
import 'package:reddit/cubit/post_notifier/post_notifier_state.dart';
import 'package:reddit/data/comment/comment_model.dart';
import 'package:reddit/functions/post_functions.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:reddit/screens/comments/add_comment_screen.dart';
import 'package:reddit/screens/posts/post_screen_cubit/post_screen_cubit.dart';
import 'package:reddit/widgets/posts/actions_cubit/post_comment_actions_cubit.dart';
import 'package:reddit/widgets/posts/votes_widget.dart';
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
    this.level = 1,
  });
  final PostModel post;

  final CommentModel comment;

  final bool stop;

  final int level;

  @override
  State<Comment> createState() => _CommentState();
}

// String content = '''[{"insert":"Heading "},
//     {"insert":"bold","attributes":{"bold":true}},{"insert":"\\n"},
//     {"insert":"bold and italic","attributes":{"bold":true,"italic":true}},
//     {"insert":"\\nsome code"},{"insert":"\\n","attributes":{"code-block":true}},
//     {"insert":"A quote"},{"insert":"\\n","attributes":{"blockquote":true}},
//     {"insert":"ordered list"},{"insert":"\\n","attributes":{"list":"ordered"}},
//     {"insert":"unordered list"},{"insert":"\\n","attributes":{"list":"bullet"}},
//     {"insert":"link","attributes":{"link":"pub.dev/packages/quill_markdown"}},{"insert":"\\n"}]''';
// String content = '''[{"insert":"Heading "},
//     {"insert":"bold and italic","attributes":{"bold":true,"italic":true}},{"insert":"\\n"},
//     {"insert":"link","attributes":{"link":"pub.dev/packages/quill_markdown"}},{"insert":"\\n"}]''';

class _CommentState extends State<Comment> {
  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();

  Future<void> _loadFromAssets() async {
    // try {
    //   final result = await rootBundle.loadString('assets/sample_data.json');
    //   final doc = Document.fromJson(jsonDecode(result));
    //   setState(() {
    //     _controller = QuillController(
    //         document: doc, selection: const TextSelection.collapsed(offset: 0));
    //   });
    // } catch (error) {
    //   final doc = Document()..insert(0, 'Empty asset');
    //   setState(() {
    //     _controller = QuillController(
    //         document: doc, selection: const TextSelection.collapsed(offset: 0));
    //   });
    // }
    Document doc;
    try {
      doc = Document.fromJson(jsonDecode(widget.comment.commentBody ?? '[]'));
    } catch (e) {
      doc = Document();
    }

    setState(() {
      _controller = QuillController(
          document: doc, selection: const TextSelection.collapsed(offset: 0));
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFromAssets();
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
        scrollable: true,
        focusNode: _focusNode,
        autoFocus: false,
        readOnly: false,
        placeholder: 'Add content',
        expands: false,
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
          ),
        ),
      ],
<<<<<<< HEAD
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onLongPress: () {
=======
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
>>>>>>> 40631d0f69581fdc20be242bf49bcd860a53f2da
          setState(() {
            widget.comment.isCollapsed = !widget.comment.isCollapsed;
          });
        },
        onTap: () {
          if (isCompressed) {
            setState(() {
              isCompressed = !isCompressed;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: widget.level > 1
                  ? BorderSide(
                      color: ColorManager.lightGrey,
                      width: 0.5.w,
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

<<<<<<< HEAD
          // margin: EdgeInsets.only(left: widget.level * 10.0),
          child: ConditionalBuilder(
            condition: isCompressed,
            builder: (context) {
              return commentAsRow(
                  post: widget.comment,
                  showContent: true,
                  content: _controller!.document
                      .toPlainText()
                      .replaceAll('\\n', ''));
            },
            fallback: (context) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: commentAsRow(
                          post: widget.comment,
                          showDots: false,
                        ),
                      ),
                    ],
                  ),
                  quillEditor,
                  // _commentsRow(),
=======
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
>>>>>>> 40631d0f69581fdc20be242bf49bcd860a53f2da

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
      ),
    );
  }

  Widget _commentsControlRow() {
    return Row(
      children: [
        const Spacer(),
        DropDownList(
          postId: widget.comment.id!,
          itemClass: ItemsClass.comment,
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
  }

  _addCommentsRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isCompressed = !isCompressed;
                  });
                },
                icon: const Icon(Icons.arrow_drop_down),
              ),
              // const  Text('Comments'),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              isCompressed = !isCompressed;
            });
          },
          icon: const Icon(Icons.arrow_drop_up),
        ),
      ],
    );
  }

  Widget commentAsRow({
    bool showDots = true,
    bool showContent = false,
    String content = '',
    required CommentModel comment,
  }) {
    return Row(
      children: [
        subredditAvatar(small: true),
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
              ' • $content',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ColorManager.greyColor,
                fontSize: 15,
              ),
            ),
          ),
<<<<<<< HEAD
        if (showDots) dropDownDots(post)
=======
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
>>>>>>> 40631d0f69581fdc20be242bf49bcd860a53f2da
      ],
    );
  }
}
