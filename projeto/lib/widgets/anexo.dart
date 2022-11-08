import 'dart:io';

import 'package:flutter/material.dart';

class Anexo extends StatelessWidget {
  final File libr;

  Anexo({Key? key, required this.libr}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.file(
              libr,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
