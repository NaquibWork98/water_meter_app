import 'package:equatable/equatable.dart';

class Tenant extends Equatable {
  final String id;
  final String name;
  final String email;
  final String location;
  final String? phoneNumber;
  final String? meterId;
  final String status;

  const Tenant({
    required this.id,
    required this.name,
    required this.email,
    required this.location,
    this.phoneNumber,
    this.meterId,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        location,
        phoneNumber,
        meterId,
      ];
}