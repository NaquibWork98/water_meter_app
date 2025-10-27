import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });

        if (mounted) {
          // Trigger OCR extraction
          context.read<MeterReadingBloc>().add(
                ImageCaptured(image.path),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });

        if (mounted) {
          // Trigger OCR extraction
          context.read<MeterReadingBloc>().add(
                ImageCaptured(image.path),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Meter Reading'),
      ),
      body: BlocConsumer<MeterReadingBloc, MeterReadingState>(
        listener: (context, state) {
        if (state is OCRReadingExtracted) {
          // Navigate to confirmation page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReadingConfirmationPage(
                meter: widget.meter,
                extractedReading: state.extractedReading,
                imagePath: state.imagePath,
              ),
            ),
          );
        } else if (state is MeterReadingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      },
        builder: (context, state) {
          return Column(
            children: [
              // Meter Info Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.meter.tenantName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppTheme.textLight,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.meter.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                    if (widget.meter.lastReading != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: AppTheme.textLight,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last Reading: ${widget.meter.lastReading} m³',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Image Preview or Placeholder
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.textLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.contain,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 64,
                                color: AppTheme.textLight.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No image captured yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textLight.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Loading indicator
              if (state is MeterReadingLoading)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        state.message ?? 'Processing...',
                        style: const TextStyle(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: state is MeterReadingLoading
                          ? null
                          : _captureImage,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        _imagePath != null ? 'Retake Photo' : 'Take Photo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: state is MeterReadingLoading
                          ? null
                          : _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose from Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: state is MeterReadingLoading
                          ? null
                          : () {
                              // Show manual entry dialog
                              _showManualEntryDialog();
                            },
                      icon: const Icon(Icons.edit),
                      label: const Text('Enter Manually'),
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

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Reading Manually'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Meter Reading',
            hintText: 'e.g., 12345.67',
            suffixText: 'm³',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                
                // Navigate to confirmation page with manual entry
                Navigator.pushReplacement(
                  this.context,
                  MaterialPageRoute(
                    builder: (context) => ReadingConfirmationPage(
                      meter: widget.meter,
                      extractedReading: controller.text,
                      imagePath: '', // No image for manual entry
                    ),
                  ),
                );
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}