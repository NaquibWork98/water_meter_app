import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/meter.dart';
import '../bloc/meter_reading_bloc.dart';
import '../bloc/meter_reading_event.dart';
import '../bloc/meter_reading_state.dart';
import 'reading_confirmation_page.dart';

class CameraCapturePage extends StatefulWidget {
  final Meter meter;

  const CameraCapturePage({
    super.key,
    required this.meter,
  });

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String? _extractedReading;
  Timer? _captureTimer;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
      _initializeCamera();
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        if (mounted) {
          _showError('No cameras available on this device');
        }
        return;
      }

      // Use back camera
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });

        // Start continuous capture for OCR
        _startContinuousCapture();
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to initialize camera: $e');
      }
    }
  }

  void _startContinuousCapture() {
    // Capture image every 1.5 seconds for real-time OCR processing
    _captureTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isProcessing && _isCameraInitialized && mounted) {
        _captureForOCR();
      }
    });
  }

  Future<void> _captureForOCR() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isProcessing) return; // Prevent overlapping captures

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile image = await _cameraController!.takePicture();

      if (mounted) {
        // Trigger OCR extraction for real-time display
        context.read<MeterReadingBloc>().add(
              ImageCaptured(image.path),
            );
      }
    } catch (e) {
      // Silent fail for continuous capture
      debugPrint('OCR capture failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _confirmReading() async {
    if (_extractedReading == null || _extractedReading!.isEmpty) {
      return;
    }

    // Stop continuous capture
    _captureTimer?.cancel();

    if (mounted) {
      // Navigate to confirmation with the extracted reading
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReadingConfirmationPage(
            meter: widget.meter,
            extractedReading: _extractedReading!,
            imagePath: '', // No specific image needed
          ),
        ),
      );
    }
  }


  Future<void> _pickFromGallery() async {
    try {
      // Stop continuous capture
      _captureTimer?.cancel();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        // Navigate directly to confirmation page
        // OCR will be triggered there if needed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReadingConfirmationPage(
              meter: widget.meter,
              extractedReading: '', // Let confirmation page handle OCR
              imagePath: image.path,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize?.height ?? 100,
          height: _cameraController!.value.previewSize?.width ?? 100,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        // Top info card
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha:0.30),
                  Colors.black.withValues(alpha:0.0),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Meter Reading',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Center guide frame with dashed border (positioned higher)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: MediaQuery.of(context).size.width * 0.075,
          right: MediaQuery.of(context).size.width * 0.075,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // Semi-transparent overlay inside the frame
              color: Colors.white.withValues(alpha: 0.20),
            ),
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: Colors.white,
                strokeWidth: 3,
                dashWidth: 20,
                dashSpace: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.center_focus_weak,
                    size: 64,
                    color: Colors.white.withValues(alpha:0.8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Align meter within the frame',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom controls and extracted reading
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha:0.8),
                  Colors.black.withValues(alpha:0.0),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Extracted reading display (always visible)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Extracted Reading',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _extractedReading ?? '-------',
                            style: TextStyle(
                              color: _extractedReading != null &&
                                      _extractedReading!.isNotEmpty
                                  ? Colors.white
                                  : Colors.white.withValues(alpha:0.3),
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Gallery button
                        OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Choose from Gallery'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Confirm button (full width)
                        ElevatedButton(
                          onPressed: _confirmReading,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // disabledBackgroundColor: AppTheme.primaryBlue.withOpacity(0.5),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),


      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<MeterReadingBloc, MeterReadingState>(
        listener: (context, state) {
          if (state is OCRReadingExtracted) {
            // Update extracted reading for real-time display
            if (mounted) {
              setState(() {
                _extractedReading = state.extractedReading;
              });
            }
          } else if (state is MeterReadingError) {
            // Only show critical errors, ignore OCR failures during scanning
            if (!state.message.contains('OCR') && 
                !state.message.contains('extract')) {
              _showError(state.message);
            }
          }
        },
        child: Stack(
          children: [
            // Camera preview (full screen)
            _buildCameraPreview(),
            
            // Overlay UI
            _buildOverlay(),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for creating dashed border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 10.0,
    this.dashSpace = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Top border
    _drawDashedLine(
      canvas,
      paint,
      const Offset(0, 0),
      Offset(size.width, 0),
    );
    
    // Right border
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, 0),
      Offset(size.width, size.height),
    );
    
    // Bottom border
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, size.height),
      Offset(0, size.height),
    );
    
    // Left border
    _drawDashedLine(
      canvas,
      paint,
      Offset(0, size.height),
      const Offset(0, 0),
    );
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    final unitX = dx / distance;
    final unitY = dy / distance;

    double currentDistance = 0;
    
    // Draw dashes until we reach or exceed the total distance
    while (currentDistance < distance) {
      final startX = start.dx + currentDistance * unitX;
      final startY = start.dy + currentDistance * unitY;
      
      // Calculate end point, but don't exceed the line end
      final remainingDistance = distance - currentDistance;
      final currentDashWidth = remainingDistance < dashWidth ? remainingDistance : dashWidth;
      
      final endX = startX + currentDashWidth * unitX;
      final endY = startY + currentDashWidth * unitY;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
      
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}