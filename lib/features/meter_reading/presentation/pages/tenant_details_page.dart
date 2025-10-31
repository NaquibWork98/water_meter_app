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
        backgroundColor: const Color(0xFFEFF3F8),
        title: const Text('Tenant Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Profile Section (Name and Status)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.primaryBlue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tenant.status,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Address Box
            _buildInfoBox(
              Icons.location_on,
              'Address',
              tenant.location,
            ),

            const SizedBox(height: 0),

            // Phone Box 
            _buildInfoBox(
              Icons.phone,
              'Phone Number',
              tenant.phoneNumber ?? 'No phone',
            ),

            const SizedBox(height: 0),

            // Email Box (Separate)
            _buildInfoBox(
              Icons.email,
              'Email',
              tenant.email,
            ),

            const SizedBox(height: 20),

            // Meter Reading History title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Meter Reading History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

  Widget _buildInfoBox(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Square icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8), // Square with rounded corners
            ),
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
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    Reading reading,
    Tenant tenant,
  ) {
    // Format the date
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final month =
        '${monthNames[reading.timestamp.month - 1]} ${reading.timestamp.year}';
    final date =
        '${reading.timestamp.day.toString().padLeft(2, '0')}/${reading.timestamp.month.toString().padLeft(2, '0')}/${reading.timestamp.year}';

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
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [  // ← Add this
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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