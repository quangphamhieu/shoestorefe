import 'dart:io';
import 'package:flutter/material.dart';

Widget getFileImage(String path) {
  return Image.file(
    File(path),
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
  );
}
