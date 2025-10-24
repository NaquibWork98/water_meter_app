import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/meter_reading_bloc.dart';
import '../bloc/meter_reading_event.dart';
import '../bloc/meter_reading_state.dart';
import 'camera_capture_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  
  bool _isScanning = true;
  bool _isTorchOn = false;  

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
        });
        
        context.read<MeterReadingBloc>().add(
          QRCodeScanned(barcode.rawValue!),
        );
        break;
      }
    }
  }

  void _toggleTorch() async {
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    await cameraController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: BlocConsumer<MeterReadingBloc, MeterReadingState>(
        listener: (context, state) {
          if (state is MeterLoaded) {
            // Navigate to camera capture page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CameraCapturePage(meter: state.meter),
              ),
            );
          } else if (state is MeterReadingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
            
            // Allow scanning again after error
            setState(() {
              _isScanning = true;
            });
          }
        },
        builder: (context, state) {
          if (state is MeterReadingLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              // Camera Scanner
              MobileScanner(
                controller: cameraController,
                onDetect: _onDetect,
              ),

              // Overlay with scanning frame
              CustomPaint(
                painter: ScannerOverlay(),
                child: Container(),
              ),

              // Scanning frame
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // Instructions
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Place QR code inside the frame to scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Manual entry button
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Manual entry coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Enter Manually',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(scanArea, const Radius.circular(16)),
          ),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}