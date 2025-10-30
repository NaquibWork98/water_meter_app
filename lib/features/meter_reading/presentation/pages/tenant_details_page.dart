import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/entities/meter.dart';
import '../../domain/entities/reading.dart';
import 'camera_capture_page.dart';
import 'reading_details_page.dart';

class TenantDetailsPage extends StatelessWidget {
  final Tenant tenant;

  const TenantDetailsPage({
    super.key,
    required this.tenant,
  });

  @override
  Widget build(BuildContext context) {
    final meter = Meter(
      id: tenant.meterId ?? '0',
      qrCode: 'QR${tenant.id}',
      location: tenant.location,
      tenantId: tenant.id,
      tenantName: tenant.name,
      tenantEmail: tenant.email,
      lastReading: null,
      lastReadingDate: null,
    );

    // TODO: Replace with actual reading history from repository
    final List<Reading> readingHistory = [
      Reading(
        id: '1',
        meterId: meter.id,
        reading: '12345.67',
        timestamp: DateTime(2025, 9, 5, 10, 30),
        submittedBy: 'System',
        isConfirmed: true,
      ),
      Reading(
        id: '2',
        meterId: meter.id,
        reading: '12245.50',
        timestamp: DateTime(2025, 8, 4, 14, 15),
        submittedBy: 'System',
        isConfirmed: true,
      ),
      Reading(
        id: '3',
        meterId: meter.id,
        reading: '12145.30',
        timestamp: DateTime(2025, 7, 7, 9, 45),
        submittedBy: 'System',
        isConfirmed: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tenant Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tenant Name
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tenant.status,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Address
                  _buildInfoRow(
                    Icons.location_on,
                    'Address',
                    tenant.location,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Phone
                  _buildInfoRow(
                    Icons.phone,
                    'Phone Number',
                    tenant.phoneNumber ?? 'No phone',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email
                  _buildInfoRow(
                    Icons.email,
                    'Email',
                    tenant.email,
                  ),
                ],
              ),
            ),

            // Meter Reading History
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meter Reading History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // History items with navigation
                  ...readingHistory.map((reading) {
                    return _buildHistoryItem(
                      context,
                      reading,
                      tenant,
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Add Meter Reading Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraCapturePage(
                          meter: meter,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Meter Reading'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryBlue,
          ),
        ),
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
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    Reading reading,
    Tenant tenant,
  ) {
    // Format the date
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = '${monthNames[reading.timestamp.month - 1]} ${reading.timestamp.year}';
    final date = '${reading.timestamp.day.toString().padLeft(2, '0')}/${reading.timestamp.month.toString().padLeft(2, '0')}/${reading.timestamp.year}';

    return GestureDetector(
      onTap: () {
        // Navigate to Reading Details Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadingDetailsPage(
              tenant: tenant,
              reading: reading,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '${reading.reading} m³',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textLight,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}