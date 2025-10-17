import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FreehandImageCropper extends StatefulWidget {
  const FreehandImageCropper({
    super.key,
    required this.title,
    required this.imagePath,
  });

  final String title;
  final Uint8List imagePath;

  @override
  _FreehandImageCropperState createState() => _FreehandImageCropperState();
}

class _FreehandImageCropperState extends State<FreehandImageCropper> {
  final CropController _controller = CropController(
    aspectRatio: null,
    defaultCrop: const Rect.fromLTRB(0, 0, 1, 1),
  );
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isCropping,
      child: Scaffold(
        body: Stack(
          children: [
            // Content that respects SafeArea
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Text(
                          'Crop Image',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 19),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CropImage(
                        controller: _controller,
                        image: Image.memory(widget.imagePath),
                        paddingSize: 0,
                        alwaysMove: true,
                        minimumImageSize: 50,
                        maximumImageSize: 10000,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            _controller.rotation = CropRotation.up;
                            _controller.crop = const Rect.fromLTRB(0, 0, 1, 1);
                            _controller.aspectRatio = null;
                          },
                          child: const Text(
                            "Reset",
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _onCropDone,
                          child: const Row(
                            children: [
                              Icon(Icons.check),
                              SizedBox(width: 8),
                              Text("Done"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Overlay (covers full screen)
            if (_isCropping)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCropDone() async {
    setState(() {
      _isCropping = true;
    });

    try {
      bool timedOut = false;
      final imageWidget = await _controller.croppedImage().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          timedOut = true;
          return Image.memory(Uint8List(0));
        },
      );

      if (timedOut ||
          (imageWidget.image is MemoryImage &&
              (imageWidget.image as MemoryImage).bytes.isEmpty)) {
        if (mounted) {
          setState(() {
            _isCropping = false;
          });
          Get.snackbar(
            "Timeout",
            "Cropping took too long or failed. Please try again.",
          );
        }
        return;
      }

      final croppedBytes = await _imageWidgetToBytes(imageWidget);
      if (mounted) {
        Navigator.pop(context, croppedBytes);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCropping = false;
        });
        Get.snackbar("Error", "Failed to crop image: $e");
      }
    }
  }

  Future<Uint8List> _imageWidgetToBytes(Image image) async {
    final completer = Completer<Uint8List>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(
      ImageStreamListener(
            (info, _) async {
          final byteData = await info.image.toByteData(
            format: ImageByteFormat.png,
          );
          if (byteData == null) {
            completer.completeError(
              Exception("Failed to convert image to bytes"),
            );
            return;
          }
          completer.complete(byteData.buffer.asUint8List());
        },
        onError: (error, stackTrace) {
          completer.completeError(error, stackTrace);
        },
      ),
    );
    return completer.future;
  }
}
