import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as imgUtils;
import 'package:path_provider/path_provider.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realestate/widget/bottom_bar.dart';
import 'package:realestate/widget/camera_preview.dart';
import 'package:realestate/widget/preview_card.dart';
import 'package:realestate/widget/top_bar.dart';
import 'package:gallery_saver/files.dart';


// class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
// class CameraPage extends GetView<PictureController> {
//   late String _lastPhotoPath;
//   // AnimationController _iconsAnimationController, _previewAnimationController;
//   // [...]
//   // Notifiers
//   ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.NONE);
//   ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
//   ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
//   ValueNotifier<Size> _photoSize = ValueNotifier(Size.infinite);

//   // Controllers
//   PictureController _pictureController = new PictureController();
//   VideoController _videoController = new VideoController();

//   _takePhoto() async {
//     final Directory extDir = await getTemporaryDirectory();
//     final testDir =
//         await Directory('${extDir.path}/test').create(recursive: true);
//     final String filePath = '${testDir.path}/photo_test.jpg';
//     await _pictureController.takePicture(filePath);

//     GallerySaver.saveImage(filePath, albumName: "TEST");
//     // lets just make our phone vibrate
//     HapticFeedback.mediumImpact();
//     _lastPhotoPath = filePath;
//     // setState(() {});
//     // if (_previewAnimationController.status == AnimationStatus.completed) {
//     //   _previewAnimationController.reset();
//     // }
//     // _previewAnimationController.forward();
//     print("----------------------------------");
//     print("TAKE PHOTO CALLED");
//     final file = File(filePath);
//     print("==> hastakePhoto : ${file.exists()} | path : $filePath");
//     final img = imgUtils.decodeImage(file.readAsBytesSync());
//     // print("==> img.width : ${img.width} | img.height : ${img.height}");
//     print("----------------------------------");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CameraAwesome(
//         testMode: false,
//         // onPermissionsResult: (bool result) { },
//         selectDefaultSize: (List<Size> availableSizes) => Size(),
//         onCameraStarted: () { },
//         // onOrientationChanged: (CameraOrientations newOrientation) { },
//         // zoom: 0.64,
//         sensor: _sensor,
//         photoSize: _photoSize,
//         switchFlashMode: _switchFlash,
//         captureMode: _captureMode,
//         fitted: true,

//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () async {
//           _takePhoto();
//         },
//         label: Text('사진'),
//         icon: Icon(Icons.camera_enhance),
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.blueAccent,
//       )
//     );
//   }
//   // [...]
// }


class CameraPage extends StatefulWidget {
  final bool randomPhotoName;

  CameraPage({this.randomPhotoName = true});

  @override
  _CameraPage createState() => _CameraPage();
}

class _CameraPage extends State<CameraPage> with TickerProviderStateMixin {
String _lastPhotoPath = "", _lastVideoPath = "";
  bool _focus = false, _fullscreen = true, _isRecordingVideo = false;

  ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.NONE);
  ValueNotifier<double> _zoomNotifier = ValueNotifier(0);
  ValueNotifier<Size> _photoSize = ValueNotifier(Size.infinite);
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<bool> _enableAudio = ValueNotifier(true);
  ValueNotifier<CameraOrientations> _orientation =
      ValueNotifier(CameraOrientations.PORTRAIT_UP);

  /// use this to call a take picture
  PictureController _pictureController = PictureController();

  /// use this to record a video
  VideoController _videoController = VideoController();

  /// list of available sizes
  late List<Size> _availableSizes;

  late AnimationController _iconsAnimationController, _previewAnimationController;
  late Animation<Offset> _previewAnimation;
  late Timer _previewDismissTimer;
  // StreamSubscription<Uint8List> previewStreamSub;
  late Stream<Uint8List> previewStream;

  @override
  void initState() {
    super.initState();
    _iconsAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _previewAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );
    _previewAnimation = Tween<Offset>(
      begin: const Offset(-2.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _previewAnimationController,
        curve: Curves.elasticOut,
        reverseCurve: Curves.elasticIn,
      ),
    );
  }

  @override
  void dispose() {
    _iconsAnimationController.dispose();
    _previewAnimationController.dispose();
    // previewStreamSub.cancel();
    _photoSize.dispose();
    _captureMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          this._fullscreen ? buildFullscreenCamera() : buildSizedScreenCamera(),
          _buildInterface(),
          (!_isRecordingVideo)
              ? PreviewCardWidget(
                  lastPhotoPath: _lastPhotoPath,
                  orientation: _orientation,
                  previewAnimation: _previewAnimation,
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildInterface() {
    return Stack(
      children: <Widget>[
        SafeArea(
          bottom: false,
          child: TopBarWidget(
              isFullscreen: _fullscreen,
              isRecording: _isRecordingVideo,
              enableAudio: _enableAudio,
              photoSize: _photoSize,
              captureMode: _captureMode,
              switchFlash: _switchFlash,
              orientation: _orientation,
              rotationController: _iconsAnimationController,
              onFlashTap: () {
                switch (_switchFlash.value) {
                  case CameraFlashes.NONE:
                    _switchFlash.value = CameraFlashes.ON;
                    break;
                  case CameraFlashes.ON:
                    _switchFlash.value = CameraFlashes.AUTO;
                    break;
                  case CameraFlashes.AUTO:
                    _switchFlash.value = CameraFlashes.ALWAYS;
                    break;
                  case CameraFlashes.ALWAYS:
                    _switchFlash.value = CameraFlashes.NONE;
                    break;
                }
                setState(() {});
              },
              onAudioChange: () {
                this._enableAudio.value = !this._enableAudio.value;
                setState(() {});
              },
              onChangeSensorTap: () {
                this._focus = !_focus;
                if (_sensor.value == Sensors.FRONT) {
                  _sensor.value = Sensors.BACK;
                } else {
                  _sensor.value = Sensors.FRONT;
                }
              },
              onResolutionTap: () => _buildChangeResolutionDialog(),
              onFullscreenTap: () {
                this._fullscreen = !this._fullscreen;
                setState(() {});
              }, enablePinchToZoom: ValueNotifier(true), onPinchToZoomChange: (() => print('')),),
        ),
        BottomBarWidget(
          onZoomInTap: () {
            if (_zoomNotifier.value <= 0.9) {
              _zoomNotifier.value += 0.1;
            }
            setState(() {});
          },
          onZoomOutTap: () {
            if (_zoomNotifier.value >= 0.1) {
              _zoomNotifier.value -= 0.1;
            }
            setState(() {});
          },
          onCaptureModeSwitchChange: () {
            if (_captureMode.value == CaptureModes.PHOTO) {
              _captureMode.value = CaptureModes.VIDEO;
            } else {
              _captureMode.value = CaptureModes.PHOTO;
            }
            setState(() {});
          },
          onCaptureTap: (_captureMode.value == CaptureModes.PHOTO)
              ? _takePhoto
              : _recordVideo,
          rotationController: _iconsAnimationController,
          orientation: _orientation,
          isRecording: _isRecordingVideo,
          captureMode: _captureMode,
        ),
      ],
    );
  }

  _takePhoto() async {
    final Directory extDir = await getTemporaryDirectory();
    final testDir =
        await Directory('${extDir.path}/test').create(recursive: true);
    final String filePath = widget.randomPhotoName
        ? '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg'
        : '${testDir.path}/photo_test.jpg';
    await _pictureController.takePicture(filePath);
    // lets just make our phone vibrate
    HapticFeedback.mediumImpact();
    _lastPhotoPath = filePath;

    GallerySaver.saveImage(filePath, albumName: "임장");

    setState(() {});
    if (_previewAnimationController.status == AnimationStatus.completed) {
      _previewAnimationController.reset();
    }
    _previewAnimationController.forward();
    // final file = File(filePath);
    // final img = imgUtils.decodeImage(file.readAsBytesSync());
  }

  _recordVideo() async {
    // lets just make our phone vibrate
    HapticFeedback.mediumImpact();

    if (this._isRecordingVideo) {
      await _videoController.stopRecordingVideo();

      _isRecordingVideo = false;
      setState(() {});

      final file = File(_lastVideoPath);
      print("----------------------------------");
      print("VIDEO RECORDED");
      print(
          "==> has been recorded : ${file.exists()} | path : $_lastVideoPath");
      print("----------------------------------");

      await Future.delayed(Duration(milliseconds: 300));
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPreview(
            videoPath: _lastVideoPath,
          ),
        ),
      );
    } else {
      final Directory extDir = await getTemporaryDirectory();
      final testDir =
          await Directory('${extDir.path}/test').create(recursive: true);
      final String filePath = widget.randomPhotoName
          ? '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4'
          : '${testDir.path}/video_test.mp4';
      await _videoController.recordVideo(filePath);
      _isRecordingVideo = true;
      _lastVideoPath = filePath;
      setState(() {});
    }
  }

  _buildChangeResolutionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) => ListTile(
          key: ValueKey("resOption"),
          onTap: () {
            this._photoSize.value = _availableSizes[index];
            setState(() {});
            Navigator.of(context).pop();
          },
          leading: Icon(Icons.aspect_ratio),
          title: Text(
              "${_availableSizes[index].width}/${_availableSizes[index].height}"),
        ),
        separatorBuilder: (context, index) => Divider(),
        itemCount: _availableSizes.length,
      ),
    );
  }

  _onOrientationChange(CameraOrientations newOrientation) {
    _orientation.value = newOrientation;
    if (_previewDismissTimer != null) {
      _previewDismissTimer.cancel();
    }
  }

  _onPermissionsResult(bool granted) {
    if (!granted) {
      AlertDialog alert = AlertDialog(
        title: Text('Error'),
        content: Text(
            'It seems you doesn\'t authorized some permissions. Please check on your settings and try again.'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {});
      print("granted");
    }
  }

  Widget buildFullscreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Center(
        child: CameraAwesome(
          // onPermissionsResult: _onPermissionsResult,
          selectDefaultSize: (availableSizes) {
            this._availableSizes = availableSizes;
            return availableSizes[0];
          },
          captureMode: _captureMode,
          photoSize: _photoSize,
          sensor: _sensor,
          enableAudio: _enableAudio,
          switchFlashMode: _switchFlash,
          zoom: _zoomNotifier,
          // onOrientationChanged: _onOrientationChange,
          // imagesStreamBuilder: (imageStream) {
          //   /// listen for images preview stream
          //   /// you can use it to process AI recognition or anything else...
          //   print("-- init CamerAwesome images stream");
          //   setState(() {
          //     previewStream = imageStream;
          //   });

          //   imageStream.listen((Uint8List imageData) {
          //     print(
          //         "...${DateTime.now()} new image received... ${imageData.lengthInBytes} bytes");
          //   });
          // },
          onCameraStarted: () {
            // camera started here -- do your after start stuff
          },
        ),
      ),
    );
  }

  Widget buildSizedScreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: CameraAwesome(
              // onPermissionsResult: _onPermissionsResult,
              selectDefaultSize: (availableSizes) {
                this._availableSizes = availableSizes;
                return availableSizes[0];
              },
              captureMode: _captureMode,
              photoSize: _photoSize,
              sensor: _sensor,
              fitted: true,
              switchFlashMode: _switchFlash,
              zoom: _zoomNotifier,
              // onOrientationChanged: _onOrientationChange,
            ),
          ),
        ),
      ),
    );
  }
}