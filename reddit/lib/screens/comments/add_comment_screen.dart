import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reddit/components/helpers/color_manager.dart';
import 'package:path/path.dart';
import 'package:reddit/constants/constants.dart';
import 'package:reddit/data/comment/sended_comment_model.dart';
import 'package:reddit/networks/dio_helper.dart';

import '../../data/comment/comment_model.dart';
import '../../data/post_model/post_model.dart';

import 'dart:async';

var logger = Logger();

class AddCommentScreen extends StatefulWidget {
  static const routeName = 'add-comment';
  const AddCommentScreen({super.key, required this.post, this.parentComment});

  /// the post to which the comment will be added
  final PostModel post;

  /// the parent comment to which the comment will be added
  /// if null, the comment will be added to the post
  final CommentModel? parentComment;

  @override
  State<AddCommentScreen> createState() => _AddCommentScreenState();
}

class _AddCommentScreenState extends State<AddCommentScreen> {
  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _controller = QuillController.basic();
    super.initState();
  }

  bool _isPostParent() => widget.parentComment == null;

  @override
  Widget build(BuildContext context) {
    var toolbar = QuillToolbar.basic(
      showUndo: false,
      showRedo: false,
      showBoldButton: false,
      showItalicButton: false,
      showBackgroundColorButton: false,
      showCenterAlignment: false,
      showLeftAlignment: false,
      showRightAlignment: false,
      showJustifyAlignment: false,
      showHeaderStyle: false,
      showListNumbers: false,
      showListBullets: false,
      showCodeBlock: false,
      showStrikeThrough: false,
      showFontSize: false,
      multiRowsDisplay: false,
      showClearFormat: false,
      showIndent: false,
      showQuote: false,
      showColorButton: false,
      showSearchButton: false,
      showDirection: false,
      showDividers: false,
      showFontFamily: false,
      showInlineCode: false,
      showListCheck: false,
      showUnderLineButton: false,
      // showSmallButton: false,
      controller: _controller!,
      embedButtons: FlutterQuillEmbeds.buttons(
        showVideoButton: false,
        showCameraButton: false,

        // provide a callback to enable picking images from device.
        // if omit, "image" button only allows adding images from url.
        // same goes for videos.
        onImagePickCallback: _onImagePickCallback,
        onVideoPickCallback: _onVideoPickCallback,
        // uncomment to provide a custom "pick from" dialog.
        // mediaPickSettingSelector: _selectMediaPickSetting,
        // uncomment to provide a custom "pick from" dialog.
        // cameraPickSettingSelector: _selectCameraPickSetting,
      ),
      showAlignmentButtons: true,
      afterButtonPressed: _focusNode.requestFocus,
    );
    if (kIsWeb) {
      toolbar = QuillToolbar.basic(
        controller: _controller!,
        embedButtons: FlutterQuillEmbeds.buttons(
          onImagePickCallback: _onImagePickCallback,
          webImagePickImpl: _webImagePickImpl,
        ),
        showAlignmentButtons: true,
        afterButtonPressed: _focusNode.requestFocus,
      );
    }
    void postComment({
      required VoidCallback onSuccess,
      required VoidCallback onError,
    }) {
      final content = jsonEncode(_controller!.document.toDelta().toJson());
      SendedCommentModel c = SendedCommentModel(
        content: content,
        postId: widget.post.id,
        haveSubreddit: widget.post.subreddit != null,
        level: _isPostParent() ? 1 : (widget.parentComment!.level! + 1),
        parentId:
            _isPostParent() ? widget.post.id : widget.parentComment!.commentId,
        subredditName: widget.post.subreddit,
      );

      DioHelper.postData(token: token, path: '/comment', data: c.toJson())
          .then((value) {
        onSuccess();




        //TODO HANDLE THIS IN THE CUBIT
        return null;
      }).catchError((e) {
        // TODO HANDLE THIS IN THE CUBIT
        onError();
        print(e);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add comment'),
        actions: [
          TextButton(
            onPressed: () {
              // check if the comment is empty
              logger.i(_controller!.document.length);
              if (_controller!.document.length == 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: ColorManager.yellow,
                    content: Text('Comment cannot be empty'),
                  ),
                );
              }

              postComment(
                onSuccess: () {
                  Navigator.of(context).pop();
                },
                onError: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: ColorManager.yellow,
                      content: Text('Error while posting comment'),
                    ),
                  );
                },
              );

              
            },
            child: const Text(
              'Post',
              style: TextStyle(color: ColorManager.blue),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          QuillEditor(
            controller: QuillController(
              document:
                  Document.fromJson(jsonDecode(widget.post.content ?? '[]')),
              selection: const TextSelection(baseOffset: 0, extentOffset: 0),
            ),
            readOnly: true,
            enableInteractiveSelection: false,
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
          const Divider(
            height: 10,
            thickness: 1,
          ),
          Expanded(
            child: QuillEditor(
              controller: _controller!,
              readOnly: false,
              autoFocus: true,
              expands: true,
              scrollable: true,
              scrollController: ScrollController(),
              focusNode: FocusNode(),
              padding: EdgeInsets.zero,
              embedBuilders: [
                ...FlutterQuillEmbeds.builders(),
              ],
            ),
          ),
          const Divider(
            height: 10,
            thickness: 2,
          ),
          Row(
            children: [
              LinkStyleButton(
                controller: _controller!,
                dialogTheme: QuillDialogTheme(
                  dialogBackgroundColor: ColorManager.darkBlack,
                  labelTextStyle: const TextStyle(color: ColorManager.blue),
                ),
                iconTheme: const QuillIconTheme(
                    iconUnselectedFillColor: Colors.transparent,
                    iconUnselectedColor: ColorManager.greyColor),
              ),
              Spacer(),
              ImageButton(
                icon: Icons.image,
                controller: _controller!,
                onImagePickCallback: _onImagePickCallback,

                // change it for web
                webImagePickImpl: _webImagePickImpl,
                fillColor: Colors.transparent,
                iconTheme: const QuillIconTheme(
                    iconUnselectedColor: ColorManager.blue),
              ),
              IconButton(
                  onPressed: () async {
                    GiphyGif? gif = await GiphyGet.getGif(
                      context: context, //Required
                      apiKey: 'Cy67mi7cCOLy9reX6CtubyaAxFbNCflL', //Required.
                      lang: GiphyLanguage
                          .english, //Optional - Language for query.
                      tabColor: Colors.teal, // Optional- default accent color.
                    );
                    if (gif != null) {
                      _linkSubmitted(gif.images?.original?.url);
                    }
                  },
                  icon: Icon(
                    Icons.gif_box_outlined,
                    color: ColorManager.blue,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _linkSubmitted(String? value) {
    if (value != null && value.isNotEmpty && _controller != null) {
      final index = _controller!.selection.baseOffset;
      final length = _controller!.selection.extentOffset - index;

      _controller!.replaceText(index, length, BlockEmbed.image(value), null);
    }
  }

  // Renders the image picked by imagePicker from local file storage
  // You can also upload the picked image to any server (eg : AWS s3
  // or Firebase) and then return the uploaded image URL.
  Future<String> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile =
        await file.copy('${appDocDir.path}/${basename(file.path)}');
    return copiedFile.path.toString();
  }

  Future<String?> _webImagePickImpl(
      OnImagePickCallback onImagePickCallback) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return null;
    }

    // Take first, because we don't allow picking multiple files.
    final fileName = result.files.first.name;
    final file = File(fileName);

    return onImagePickCallback(file);
  }

  // Renders the video picked by imagePicker from local file storage
  // You can also upload the picked video to any server (eg : AWS s3
  // or Firebase) and then return the uploaded video URL.
  Future<String> _onVideoPickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile =
        await file.copy('${appDocDir.path}/${basename(file.path)}');
    return copiedFile.path.toString();
  }
}
