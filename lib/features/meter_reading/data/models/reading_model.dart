import '../../domain/entities/reading.dart';

class ReadingModel extends Reading {
  const ReadingModel({
    required super.id,
    required super.meterId,
    required super.reading,
    super.imagePath,
    required super.timestamp,
    super.submittedBy,
    super.isConfirmed,
  });

  factory ReadingModel.fromJson(Map<String, dynamic> json) {
    return ReadingModel(
      id: json['id'] as String,
      meterId: json['meter_id'] as String,
      reading: json['reading'] as String,
      imagePath: json['image_path'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      submittedBy: json['submitted_by'] as String?,
      isConfirmed: json['is_confirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meter_id': meterId,
      'reading': reading,
      'image_path': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'submitted_by': submittedBy,
      'is_confirmed': isConfirmed,
    };
  }

  Reading toEntity() {
    return Reading(
      id: id,
      meterId: meterId,
      reading: reading,
      imagePath: imagePath,
      timestamp: timestamp,
      submittedBy: submittedBy,
      isConfirmed: isConfirmed,
    );
  }

  factory ReadingModel.fromEntity(Reading reading) {
    return ReadingModel(
      id: reading.id,
      meterId: reading.meterId,
      reading: reading.reading,
      imagePath: reading.imagePath,
      timestamp: reading.timestamp,
      submittedBy: reading.submittedBy,
      isConfirmed: reading.isConfirmed,
    );
  }
}