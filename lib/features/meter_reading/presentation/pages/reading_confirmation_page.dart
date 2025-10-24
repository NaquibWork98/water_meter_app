import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
        automaticallyImplyLeading: false,
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
                  // Meter Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meter Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.person,
                            'Tenant',
                            widget.meter.tenantName,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.location_on,
                            'Location',
                            widget.meter.location,
                          ),
                          if (widget.meter.lastReading != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.water_drop,
                              'Last Reading',
                              '${widget.meter.lastReading} m³',
                            ),
                          ],
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Date',
                            DateFormat('dd MMM yyyy, HH:mm')
                                .format(DateTime.now()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image Preview (if available)
                  if (widget.imagePath.isNotEmpty) ...[
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Captured Image',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            child: Image.file(
                              File(widget.imagePath),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Reading Input Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meter Reading',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _readingController,
                            enabled: !isLoading,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Reading Value',
                              hintText: 'Enter meter reading',
                              suffixText: 'm³',
                              prefixIcon: const Icon(Icons.water_drop),
                              helperText: 'Verify and edit if needed',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                              // Optional: Check if reading is less than last reading
                              if (widget.meter.lastReading != null) {
                                final lastReading =
                                    double.tryParse(widget.meter.lastReading!);
                                if (lastReading != null && number < lastReading) {
                                  return 'Reading cannot be less than last reading ($lastReading m³)';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _confirmReading,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Confirm & Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Retake Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textLight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}