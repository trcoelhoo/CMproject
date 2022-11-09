import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:get/get.dart';
import 'package:projeto/preview_page.dart';
import 'package:projeto/widgets/anexo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Camera extends StatefulWidget {
  Camera({Key? key}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  File? libr;
  final picker = ImagePicker();

  Future getFileFromGallery() async {
    PickedFile? file = await picker.getImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => libr = File(file.path));
    }
  }

  showPreview(file) async {
    File? arq = await Get.to(() => PreviewPage(file: file));

    if (arq != null) {
      setState(() => libr = arq);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Take pictures to remember!"),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black26,
      ),
      backgroundColor: Colors.black12,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (libr != null) Anexo(libr: libr!),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() =>
                        CameraCamera(onFile: (file) => showPreview(file)));
                    requestCameraPermission();
                  },
                  icon: Icon(Icons.camera_alt),
                  label: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Take a picture'),
                  ),
                  style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      textStyle: TextStyle(
                        fontSize: 18,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('or'),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.attach_file),
                  label: Text('Update a picture'),
                  onPressed: () => getFileFromGallery(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void requestCameraPermission() async {
  /// status can either be: granted, denied, restricted or permanentlyDenied
  var status = await Permission.camera.status;
  if (status.isGranted) {
    print("Permission is granted");
  }
  if (status.isDenied) {
    if (await Permission.camera.request().isGranted) {
      print("Permission was granted");
    }
  }

  if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}
