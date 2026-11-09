// ignore_for_file: use_null_aware_elements

import 'dart:io';

enum DriverProfileEditType {
  profile,
  driverLicense,
  insurance,
  vehicleRegistration,
  vehicleDetails,
}

extension DriverProfileEditTypeX on DriverProfileEditType {
  String get pathSegment {
    switch (this) {
      case DriverProfileEditType.profile:
        return 'profile';
      case DriverProfileEditType.driverLicense:
        return 'driver-license';
      case DriverProfileEditType.insurance:
        return 'insurance';
      case DriverProfileEditType.vehicleRegistration:
        return 'vehicle-registration';
      case DriverProfileEditType.vehicleDetails:
        return 'vehicle-details';
    }
  }

  bool get requiresMultipart => this != DriverProfileEditType.vehicleDetails;
}

class VehicleDetailsUpdatePayload {
  final String make;
  final String model;
  final int yearOfManufacture;
  final String color;
  final String vehicleIdentificationNumber;
  final String licensePlateNumber;
  final String registrationNumber;
  final String regionOfRegistration;
  final String expiryDate;
  final String vehicleType;

  const VehicleDetailsUpdatePayload({
    required this.make,
    required this.model,
    required this.yearOfManufacture,
    required this.color,
    required this.vehicleIdentificationNumber,
    required this.licensePlateNumber,
    required this.registrationNumber,
    required this.regionOfRegistration,
    required this.expiryDate,
    required this.vehicleType,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'make': make,
      'model': model,
      'yearOfManufacture': yearOfManufacture,
      'color': color,
      'vehicleIdentificationNumber': vehicleIdentificationNumber,
      'licensePlateNumber': licensePlateNumber,
      'registrationNumber': registrationNumber,
      'regionOfRegistration': regionOfRegistration,
      'expiryDate': expiryDate,
      'vehicleType': vehicleType,
    };
  }
}

class UpdateDriverProfileParams {
  final DriverProfileEditType type;
  final String? firstName;
  final String lastName;
  final String? ssn;
  final String? email;
  final String? address;
  final String? street;
  final String? city;
  final String? state;
  final String? expiryDate;
  final String? licenseNumber;
  final VehicleDetailsUpdatePayload? vehicleDetails;
  final List<File> files;

  const UpdateDriverProfileParams._({
    required this.type,
    this.firstName,
    required this.lastName,
    this.email,
    this.ssn,
    this.address,
    this.street,
    this.city,
    this.state,
    this.expiryDate,
    this.licenseNumber,
    this.vehicleDetails,
    this.files = const <File>[],
  });

  factory UpdateDriverProfileParams.profile({
    required String firstName,
    required String lastName,
    required String email,
    required String ssn,
    String? street,
    String? city,
    String? state,
    String? address,
    File? file,
  }) {
    final computedAddress =
        address ??
        ((street != null &&
                street.trim().isNotEmpty &&
                city != null &&
                city.trim().isNotEmpty)
            ? '${street.trim()}, ${city.trim()}'
            : (street ?? city ?? address));
    return UpdateDriverProfileParams._(
      type: DriverProfileEditType.profile,
      firstName: firstName,
      lastName: lastName,
      email: email,
      ssn: ssn.toString(),
      street: street,
      city: city,
      state: state,
      address: computedAddress,
      files: file == null ? const <File>[] : <File>[file],
    );
  }

  factory UpdateDriverProfileParams.driverLicense({
    required String expiryDate,
    required String licenseNumber,
    File? frontImage,
    File? backImage,
  }) {
    final payloadFiles = <File>[
      if (frontImage != null) frontImage,
      if (backImage != null) backImage,
    ];
    return UpdateDriverProfileParams._(
      type: DriverProfileEditType.driverLicense,
      lastName: '',
      expiryDate: expiryDate,
      licenseNumber: licenseNumber,
      files: payloadFiles,
    );
  }

  factory UpdateDriverProfileParams.insurance({
    File? frontImage,
    File? backImage,
  }) {
    final payloadFiles = <File>[
      if (frontImage != null) frontImage,
      if (backImage != null) backImage,
    ];
    return UpdateDriverProfileParams._(
      type: DriverProfileEditType.insurance,
      lastName: '',
      files: payloadFiles,
    );
  }

  factory UpdateDriverProfileParams.vehicleRegistration({
    File? frontImage,
    File? backImage,
  }) {
    final payloadFiles = <File>[
      if (frontImage != null) frontImage,
      if (backImage != null) backImage,
    ];
    return UpdateDriverProfileParams._(
      type: DriverProfileEditType.vehicleRegistration,
      lastName: '',
      files: payloadFiles,
    );
  }

  factory UpdateDriverProfileParams.vehicleDetails({
    required VehicleDetailsUpdatePayload payload,
  }) {
    return UpdateDriverProfileParams._(
      type: DriverProfileEditType.vehicleDetails,
      lastName: '',
      vehicleDetails: payload,
    );
  }

  Map<String, dynamic> toFields() {
    switch (type) {
      case DriverProfileEditType.profile:
        return <String, dynamic>{
          if (firstName != null) 'firstName': firstName,
          'lastName': lastName,
          if (email != null) 'email': email,
          if (ssn != null) 'ssn': ssn,
          if (street != null) 'street': street,
          if (city != null) 'city': city,
          if (state != null) 'state': state,
          if (address != null) 'address': address,
        };
      case DriverProfileEditType.driverLicense:
        return <String, dynamic>{
          if (expiryDate != null) 'expiryDate': expiryDate,
          if (licenseNumber != null) 'licenseNumber': licenseNumber,
        };
      case DriverProfileEditType.insurance:
        return <String, dynamic>{};
      case DriverProfileEditType.vehicleRegistration:
        return <String, dynamic>{};
      case DriverProfileEditType.vehicleDetails:
        return vehicleDetails?.toJson() ?? <String, dynamic>{};
    }
  }
}
