import 'dart:convert';
import 'dart:math';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:reddit/components/helpers/color_manager.dart';
import 'package:reddit/cubit/post_notifier/post_notifier_cubit.dart';
import 'package:reddit/cubit/post_notifier/post_notifier_state.dart';
import 'package:reddit/data/comment/comment_model.dart';
import 'package:reddit/functions/post_functions.dart';
import 'package:reddit/screens/comments/add_comment_screen.dart';
import 'package:reddit/widgets/posts/cubit/post_cubit.dart';
import 'package:reddit/widgets/posts/votes_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../data/post_model/post_model.dart';
import '../posts/dropdown_list.dart';

class Comment extends StatefulWidget {
  const Comment({
    super.key,
    required this.post,
    required this.comment,
    this.stop = false,
    this.level = 0,
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
  bool isCompressed = false;
  quill.QuillController? _controller;
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
    quill.Document doc;
    try {
      doc = quill.Document.fromJson(
          jsonDecode(widget.comment.commentBody ?? '[]'));
    } catch (e) {
      doc = quill.Document();
    }

    setState(() {
      _controller = quill.QuillController(
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

    return BlocProvider(
      create: (context) => PostAndCommentActionsCubit(
        post: widget.post,
        currentComment: widget.comment,
      ),
      child: Container(
        color: ColorManager.darkGrey,
        // margin: EdgeInsets.only(left: widget.level * 10.0),
        padding: const EdgeInsets.all(8.0),
        child: ConditionalBuilder(
          condition: isCompressed,
          builder: (context) {
            return Row(
              children: [
                singleRow(post: widget.post, showIcon: true),
              ],
            );
          },
          fallback: (context) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: singleRow(
                        post: widget.post,
                        showDots: false,
                        showIcon: true,
                      ),
                    ),
                  ],
                ),
                quill.QuillEditor(
                  controller: _controller!,
                  readOnly: true,
                  autoFocus: false,
                  expands: false,
                  scrollable: false,
                  scrollController: ScrollController(),
                  focusNode: FocusNode(),
                  padding: EdgeInsets.zero,
                  embedBuilders: [
                    ...FlutterQuillEmbeds.builders(),
                  ],
                ),
                // _commentsRow(),
                _commentsControlRow(),
              ],
            );
          },
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
                          )));
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
}
