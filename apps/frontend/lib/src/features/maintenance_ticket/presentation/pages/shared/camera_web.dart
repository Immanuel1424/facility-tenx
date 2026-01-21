import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

// Web-specific camera implementation using MediaDevices API
Future<PlatformFile?> pickImageFromCamera() async {
  final completer = Completer<PlatformFile?>();
  bool isCompleted = false;

  void safeComplete(PlatformFile? file) {
    if (!isCompleted && !completer.isCompleted) {
      isCompleted = true;
      completer.complete(file);
    }
  }

  try {
    // Check if MediaDevices API is available
    final navigator = html.window.navigator;
    final mediaDevices = navigator.mediaDevices;

    if (mediaDevices == null) {
      safeComplete(null);
      return completer.future;
    }

    // Request camera access
    final stream = await mediaDevices.getUserMedia({
      'video': {
        'facingMode': 'environment', // Prefer back camera
        'width': {'ideal': 1920},
        'height': {'ideal': 1080},
      }
    });

    // Create video element to display camera feed
    final video = html.VideoElement()
      ..autoplay = true
      ..setAttribute('playsinline', 'true')
      ..style.position = 'fixed'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.zIndex = '9999'
      ..style.backgroundColor = '#000';

    // Create canvas to capture image
    final canvas = html.CanvasElement()
      ..width = 1920
      ..height = 1080;

    // Create bottom control bar
    final controlBar = html.DivElement()
      ..style.position = 'fixed'
      ..style.bottom = '0'
      ..style.left = '0'
      ..style.right = '0'
      ..style.zIndex = '10000'
      ..style.backgroundColor = 'rgba(0, 0, 0, 0.8)'
      ..style.padding = '20px'
      ..style.display = 'flex'
      ..style.justifyContent = 'center'
      ..style.alignItems = 'center'
      ..style.gap = '16px'
      ..style.boxShadow = '0 -2px 10px rgba(0, 0, 0, 0.3)';

    // Create capture button
    final captureButton = html.ButtonElement()
      ..text = 'Capture'
      ..style.padding = '14px 32px'
      ..style.fontSize = '16px'
      ..style.fontWeight = '600'
      ..style.backgroundColor = '#2196F3'
      ..style.color = 'white'
      ..style.border = 'none'
      ..style.borderRadius = '8px'
      ..style.cursor = 'pointer'
      ..style.outline = 'none'
      ..style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.3)'
      ..style.transition = 'all 0.2s';

    // Add hover effect for capture button
    captureButton.onMouseEnter.listen((e) {
      captureButton.style.backgroundColor = '#1976D2';
      captureButton.style.transform = 'scale(1.05)';
    });
    captureButton.onMouseLeave.listen((e) {
      captureButton.style.backgroundColor = '#2196F3';
      captureButton.style.transform = 'scale(1)';
    });

    // Create cancel button
    final cancelButton = html.ButtonElement()
      ..text = 'Cancel'
      ..style.padding = '14px 32px'
      ..style.fontSize = '16px'
      ..style.fontWeight = '500'
      ..style.backgroundColor = 'transparent'
      ..style.color = 'white'
      ..style.border = '2px solid rgba(255, 255, 255, 0.5)'
      ..style.borderRadius = '8px'
      ..style.cursor = 'pointer'
      ..style.outline = 'none'
      ..style.transition = 'all 0.2s';

    // Add hover effect for cancel button
    cancelButton.onMouseEnter.listen((e) {
      cancelButton.style.backgroundColor = 'rgba(255, 255, 255, 0.1)';
      cancelButton.style.borderColor = 'white';
    });
    cancelButton.onMouseLeave.listen((e) {
      cancelButton.style.backgroundColor = 'transparent';
      cancelButton.style.borderColor = 'rgba(255, 255, 255, 0.5)';
    });

    controlBar.children.add(cancelButton);
    controlBar.children.add(captureButton);

    // Add elements to body
    html.document.body!.children.add(video);
    html.document.body!.children.add(controlBar);

    // Set video source
    video.srcObject = stream;

    void cleanup() {
      stream.getTracks().forEach((track) => track.stop());
      video.srcObject = null;
      video.remove();
      controlBar.remove();
    }

    // Handle capture
    captureButton.onClick.listen((event) async {
      if (isCompleted) return;
      
      try {
        // Set canvas dimensions to match video
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;

        // Draw video frame to canvas
        final context = canvas.context2D;
        context.drawImage(video, 0, 0);

        // Convert canvas to blob
        canvas.toBlob('image/jpeg', 0.9).then((blob) {
          if (isCompleted) return;
          
          final reader = html.FileReader();
          bool readerCompleted = false;
          
          reader.onLoadEnd.listen((event) {
            if (readerCompleted || isCompleted) return;
            readerCompleted = true;
            
            final bytes = reader.result as Uint8List?;
            if (bytes != null) {
              safeComplete(
                PlatformFile(
                  name: 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
                  size: bytes.length,
                  bytes: bytes,
                ),
              );
            } else {
              safeComplete(null);
            }
            cleanup();
          });
          
          reader.onError.listen((error) {
            if (readerCompleted || isCompleted) return;
            readerCompleted = true;
            safeComplete(null);
            cleanup();
          });
          
          reader.readAsArrayBuffer(blob);
        }).catchError((error) {
          if (isCompleted) return;
          safeComplete(null);
          cleanup();
        });
      } catch (e) {
        if (isCompleted) return;
        safeComplete(null);
        cleanup();
      }
    });

    // Handle cancel
    cancelButton.onClick.listen((event) {
      if (isCompleted) return;
      safeComplete(null);
      cleanup();
    });

    // Wait for video to be ready
    video.onLoadedMetadata.listen((event) {
      // Video is ready
    });

  } catch (e) {
    // Fallback to file input method if MediaDevices fails
    return _pickImageFromCameraFallback();
  }

  return completer.future;
}

// Fallback method using file input
Future<PlatformFile?> _pickImageFromCameraFallback() async {
  final completer = Completer<PlatformFile?>();
  bool isCompleted = false;

  final input = html.FileUploadInputElement()
    ..accept = 'image/*';
  input.setAttribute('capture', 'camera');
  input.setAttribute('capture', 'environment');
  input.style.display = 'none';
  html.document.body?.append(input);

  Timer(const Duration(seconds: 30), () {
    if (!isCompleted && !completer.isCompleted) {
      isCompleted = true;
      completer.complete(null);
      input.remove();
    }
  });

  input.onChange.listen((event) {
    if (isCompleted) return;

    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((event) {
        if (isCompleted) return;
        isCompleted = true;

        final bytes = reader.result as Uint8List?;
        if (bytes != null) {
          completer.complete(
            PlatformFile(
              name: file.name,
              size: file.size,
              bytes: bytes,
            ),
          );
        } else {
          completer.complete(null);
        }
        input.remove();
      });

      reader.onError.listen((error) {
        if (isCompleted) return;
        isCompleted = true;
        completer.complete(null);
        input.remove();
      });

      reader.readAsArrayBuffer(file);
    } else {
      if (!isCompleted) {
        isCompleted = true;
        completer.complete(null);
        input.remove();
      }
    }
  });

  input.click();
  return completer.future;
}

