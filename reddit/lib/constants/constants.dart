import 'package:flutter/material.dart';

const bool isMobile = true;
const base = 'https://55ecaf8b-ca21-44a2-8a9d-78f54e672050.mock.pstmn.io';
const base2 = 'https://6e2c5270-ca4f-4bb5-bd95-0db35da6091e.mock.pstmn.io';
const List<String> labels = ['Image', 'Video', 'Text', 'Link'];
const List<IconData> icons = [
  Icons.image_outlined,
  Icons.play_circle_outline,
  Icons.article_outlined,
  Icons.add_link_outlined,
];
const List<IconData> selectedIcons = [
  Icons.image_rounded,
  Icons.play_circle_fill_rounded,
  Icons.article,
  Icons.add_link_outlined,
];

const List<String> postTypes = [
  'image',
  'video',
  'hybrid',
  'link',
  '',
  'hybrid'
];
