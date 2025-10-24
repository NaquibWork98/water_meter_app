import 'package:equatable/equatable.dart';

class Reading extends Equatable {
  final String id;
  final String meterId;
  final String reading;
  final String? imagePath;
  final DateTime timestamp;
  final String? submittedBy;
  final bool isConfirmed;

  const Reading({
    required this.id,
    required this.meterId,
    required this.reading,
    this.imagePath,
    required this.timestamp,
    this.submittedBy,
    this.isConfirmed = false,
  });

  @override
  List<Object?> get props => [
        id,
        meterId,
        reading,
        imagePath,
        timestamp,
        submittedBy,
        isConfirmed,
      ];
}