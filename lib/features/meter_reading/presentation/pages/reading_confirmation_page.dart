import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/meter.dart';
import '../../domain/entities/reading.dart';
import '../bloc/meter_reading_bloc.dart';
import '../bloc/meter_reading_event.dart';  
import '../bloc/meter_reading_state.dart'; 
import 'home_page.dart';

class ReadingConfirmationPage extends StatefulWidget {
  final Meter meter;
  final String extractedReading;
  final String imagePath;

  const ReadingConfirmationPage({
    super.key,
    required this.meter,
    required this.extractedReading,
    required this.imagePath,
  });

  @override
  State<ReadingConfirmationPage> createState() =>
      _ReadingConfirmationPageState();
}

class _ReadingConfirmationPageState extends State<ReadingConfirmationPage> {
  late TextEditingController _readingController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _readingController = TextEditingController(text: widget.extractedReading);
  }

  @override
  void dispose() {
    _readingController.dispose();
    super.dispose();
  }

  void _confirmReading() {
    if (_formKey.currentState!.validate()) {
      final reading = Reading(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        meterId: widget.meter.id,
        reading: _readingController.text,
        imagePath: widget.imagePath.isNotEmpty ? widget.imagePath : null,
        timestamp: DateTime.now(),
        isConfirmed: true,
      );

      context.read<MeterReadingBloc>().add(ReadingConfirmed(reading));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Reading'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<MeterReadingBloc, MeterReadingState>(
        listener: (context, state) {
          if (state is ReadingSubmitted) {
            // Show success dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.1),  
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppTheme.successGreen,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Upload Successful!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      // Reset bloc and navigate to home
                      context.read<MeterReadingBloc>().add(MeterReadingReset());
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                    ),
                    child: const Text('Back to Home'),
                  ),
                ],
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
          final isLoading = state is MeterReadingLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header text
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Review the meter reading extracted from\nthe photo. Edit if needed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image Preview (if available)
                  if (widget.imagePath.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imagePath),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Reading Input
                  const Text(
                    'Meter Reading',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _readingController,
                    enabled: !isLoading,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0000000',
                      suffixIcon: const Icon(
                        Icons.edit,
                        color: AppTheme.primaryBlue,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryBlue,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.primaryBlue.withValues(alpha:0.3),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryBlue,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reading';
                      }
                      final number = double.tryParse(value);
                      if (number == null) {
                        return 'Please enter a valid number';
                      }
                      if (number < 0) {
                        return 'Reading cannot be negative';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),

                  // Action Buttons
                  if (isLoading)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text(
                            'Submitting reading...',
                            style: TextStyle(color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Retake Photo button
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Confirm & Save button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _confirmReading,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirm & Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}