import 'package:http/http.dart' as http;
import '../models/meter_model.dart';
import '../models/reading_model.dart';
import '../models/tenant_model.dart';

abstract class MeterRemoteDataSource {
  Future<MeterModel> getMeterByQRCode(String qrCode);
  Future<List<MeterModel>> getAllMeters();
  Future<void> submitReading(ReadingModel reading);
  Future<List<ReadingModel>> getReadingHistory(String meterId);
  Future<List<TenantModel>> getAllTenants();
  Future<TenantModel> getTenantById(String tenantId);
}

class MeterRemoteDataSourceImpl implements MeterRemoteDataSource {
  final http.Client client;

  MeterRemoteDataSourceImpl({required this.client});

  @override
  Future<MeterModel> getMeterByQRCode(String qrCode) async {
    // MOCK DATA - Replace with real API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate finding meter by QR code
    return const MeterModel(
      id: '1',
      qrCode: 'QR123456',
      location: 'Ground Floor 02',
      tenantId: '1',
      tenantName: 'Alex Jee',
      tenantEmail: 'alexjee@gmail.com',
      lastReading: '10235.67',
      lastReadingDate: null,
    );

    // TODO: Replace with real API call
    // try {
    //   final response = await client.get(
    //     Uri.parse('${AppConstants.baseUrl}${AppConstants.getMeterEndpoint}/$qrCode'),
    //     headers: {'Content-Type': 'application/json'},
    //   ).timeout(const Duration(milliseconds: AppConstants.connectionTimeout));
    //
    //   if (response.statusCode == 200) {
    //     final jsonResponse = json.decode(response.body);
    //     return MeterModel.fromJson(jsonResponse['data']);
    //   } else {
    //     throw ServerException('Failed to get meter: ${response.statusCode}');
    //   }
    // } catch (e) {
    //   throw ServerException('Network error: $e');
    // }
  }

  @override
  Future<List<MeterModel>> getAllMeters() async {
    // MOCK DATA
    await Future.delayed(const Duration(seconds: 1));
    
    return const [
      MeterModel(
        id: '1',
        qrCode: 'QR123456',
        location: 'Ground Floor 02',
        tenantId: '1',
        tenantName: 'Alex Jee',
        tenantEmail: 'alexjee@gmail.com',
        lastReading: '10235.67',
      ),
      MeterModel(
        id: '2',
        qrCode: 'QR123457',
        location: 'Level 1, Unit 03',
        tenantId: '2',
        tenantName: 'Ahmad Javen',
        tenantEmail: 'ahmadjaven@gmail.com',
        lastReading: '8542.33',
      ),
    ];
  }

  @override
  Future<void> submitReading(ReadingModel reading) async {
    // MOCK - Just simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // TODO: Replace with real API call
    // try {
    //   final response = await client.post(
    //     Uri.parse('${AppConstants.baseUrl}${AppConstants.submitReadingEndpoint}'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: json.encode(reading.toJson()),
    //   ).timeout(const Duration(milliseconds: AppConstants.connectionTimeout));
    //
    //   if (response.statusCode != 200 && response.statusCode != 201) {
    //     throw ServerException('Failed to submit reading');
    //   }
    // } catch (e) {
    //   throw ServerException('Network error: $e');
    // }
  }

  @override
  Future<List<ReadingModel>> getReadingHistory(String meterId) async {
    // MOCK DATA
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      ReadingModel(
        id: '1',
        meterId: meterId,
        reading: '10235.67',
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        submittedBy: 'Staff 1',
        isConfirmed: true,
      ),
      ReadingModel(
        id: '2',
        meterId: meterId,
        reading: '10135.50',
        timestamp: DateTime.now().subtract(const Duration(days: 60)),
        submittedBy: 'Staff 1',
        isConfirmed: true,
      ),
    ];
  }

  @override
  Future<List<TenantModel>> getAllTenants() async {
    // MOCK DATA
    await Future.delayed(const Duration(seconds: 1));
    
    return const [
      TenantModel(
        id: '1',
        name: 'Alex Jee',
        email: 'alexjee@gmail.com',
        location: 'Ground Floor 02',
        phoneNumber: '+60123456789',
        meterId: '1',
        status: 'Active',
      ),
      TenantModel(
        id: '2',
        name: 'Ahmad Javen',
        email: 'ahmadjaven@gmail.com',
        location: 'Level 1, Unit 03',
        phoneNumber: '+60123456788',
        meterId: '2',
        status: 'Pending',
      ),
      TenantModel(
        id: '3',
        name: 'Chew Sing Siong',
        email: 'chewsingsiong@gmail.com',
        location: 'Level 2, Unit 05',
        phoneNumber: '+60123456787',
        meterId: '3',
        status: 'Overdue',
      ),
    ];
  }

  @override
  Future<TenantModel> getTenantById(String tenantId) async {
    // MOCK DATA
    await Future.delayed(const Duration(seconds: 1));
    
    return const TenantModel(
      id: '1',
      name: 'Alex Jee',
      email: 'alexjee@gmail.com',
      location: 'Ground Floor 02',
      phoneNumber: '+60123456789',
      meterId: '1',
      status: 'Active',
    );
  }
}