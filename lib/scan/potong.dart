import 'dart:io';  
import 'package:flutter/material.dart';  
import 'package:image_cropper/image_cropper.dart';  
import 'package:skinsensai/scan/kamera.dart';  

class CropImageScreen extends StatefulWidget {  
  final File imageFile;  
  final File originalImage;  

  const CropImageScreen({super.key, required this.imageFile, required this.originalImage});  

  @override  
  _CropImageScreenState createState() => _CropImageScreenState();  
}  

class _CropImageScreenState extends State<CropImageScreen> {  
  CroppedFile? _croppedFile;  

  @override  
  void initState() {  
    super.initState();  
    _cropImage();  
  }  

  Future<void> _cropImage() async {  
    _croppedFile = await ImageCropper().cropImage(  
      sourcePath: widget.imageFile.path,  
      uiSettings: [  
        AndroidUiSettings(  
          toolbarTitle: 'Potong Gambar',  
          toolbarColor: const Color.fromRGBO(81, 180, 196, 1),  
          toolbarWidgetColor: Colors.white,  
          initAspectRatio: CropAspectRatioPreset.original,  
          cropFrameColor: Colors.white,  
          lockAspectRatio: false,  
          activeControlsWidgetColor: const Color.fromRGBO(81, 180, 196, 1),  
        ),  
        IOSUiSettings(  
          title: 'Crop Image',  
          doneButtonTitle: 'Done',  
          cancelButtonTitle: 'Cancel',  
          aspectRatioLockEnabled: false,  
        ),  
      ],  
    );  

    if (_croppedFile != null) {  
      Navigator.pop(context, File(_croppedFile!.path));  
    } else {  
      Navigator.pushReplacement(  
        context,  
        MaterialPageRoute(  
          builder: (context) => CameraScreen(),  
        ),  
      );  
    }  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      body: Center(  
        child: _croppedFile == null  
            ? const CircularProgressIndicator()  
            : Image.file(File(_croppedFile!.path)),  
      ),  
    );  
  }  
}