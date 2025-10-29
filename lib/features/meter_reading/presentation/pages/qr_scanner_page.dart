import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/meter_reading_bloc.dart';
import '../bloc/meter_reading_event.dart';
import '../bloc/meter_reading_state.dart';
import 'camera_capture_page.dart';

// Function to show QR Scanner as a bottom sheet
void showQRScannerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const QRScannerBottomSheet(),
  );
}

class QRScannerBottomSheet extends StatefulWidget {
  const QRScannerBottomSheet({super.key});

  @override
  State<QRScannerBottomSheet> createState() => _QRScannerBottomSheetState();
}

class _QRScannerBottomSheetState extends State<QRScannerBottomSheet> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  
  bool _isScanning = true;
  bool _isTorchOn = false;
  double _zoomLevel = 0.0;

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
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BlocConsumer<MeterReadingBloc, MeterReadingState>(
        listener: (context, state) {
          if (state is MeterLoaded) {
            Navigator.pop(context); // Close bottom sheet
            Navigator.push(
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
            
            setState(() {
              _isScanning = true;
            });
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_on : Icons.flash_off,
                            color: AppTheme.textDark,
                          ),
                          onPressed: _toggleTorch,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.flip_camera_ios,
                            color: AppTheme.textDark,
                          ),
                          onPressed: () => cameraController.switchCamera(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Description
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Scan the QR Code located on the meter reading to automatically open tenant profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textLight.withAlpha(204),
                  ),
                ),
              ),

              // Camera View
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withAlpha(51),
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      if (state is MeterReadingLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else
                        MobileScanner(
                          controller: cameraController,
                          onDetect: _onDetect,
                        ),
                      
                      // Scanning frame overlay
                      Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryBlue,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              // Corner decorations
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: AppTheme.primaryBlue,
                                        width: 4,
                                      ),
                                      left: BorderSide(
                                        color: AppTheme.primaryBlue,
                                        width: 4,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: AppTheme.primaryBlue,
                                        width: 4,
                                      ),
                                      right: BorderSide(
                                        color: AppTheme.primaryBlue,
                                        width: 4,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppTheme.primaryBlue,
                                        width: 4,
                                      ),
                                      left: BorderSide(
                                        color: AppTheme.primaryBlue,
                                        width: 4,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppTheme.primaryBlue,
                                        width: 4,
                                      ),
                                      right: BorderSide(
                                        color: AppTheme.primaryBlue,
                                        width: 4,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Zoom Slider
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Zoom',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _zoomLevel,
                      min: 0.0,
                      max: 1.0,
                      activeColor: AppTheme.primaryBlue,
                      onChanged: (value) {
                        setState(() {
                          _zoomLevel = value;
                        });
                        cameraController.setZoomScale(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Keep the old page for backward compatibility if needed
class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Immediately show bottom sheet and pop this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
      showQRScannerBottomSheet(context);
    });
    
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}