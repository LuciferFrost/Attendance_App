class UserProfileModel {
  const UserProfileModel({
    required this.name,
    required this.employeeCode,
    required this.department,
    required this.designation,
    required this.role,
    this.dateOfBirth,
    this.employeeStatus = 'Active',
    this.workEmail,
    this.personalEmail,
    this.contactNumber,
    this.whatsappNumber,
    this.address,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.reportingManager,
    this.workType,
    this.officeLocation,
    this.shiftPolicy,
    this.joiningDate,
    this.profileImagePath,
  });

  final String name;
  final String employeeCode;
  final String department;
  final String designation;
  final String role;
  final String? dateOfBirth;
  final String employeeStatus;
  final String? workEmail;
  final String? personalEmail;
  final String? contactNumber;
  final String? whatsappNumber;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? reportingManager;
  final String? workType;
  final String? officeLocation;
  final String? shiftPolicy;
  final String? joiningDate;
  final String? profileImagePath;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  UserProfileModel copyWith({
    String? personalEmail,
    String? emergencyContactName,
    String? emergencyContactNumber,
    String? profileImagePath,
  }) {
    return UserProfileModel(
      name: name,
      employeeCode: employeeCode,
      department: department,
      designation: designation,
      role: role,
      dateOfBirth: dateOfBirth,
      employeeStatus: employeeStatus,
      workEmail: workEmail,
      personalEmail: personalEmail ?? this.personalEmail,
      contactNumber: contactNumber,
      whatsappNumber: whatsappNumber,
      address: address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactNumber:
      emergencyContactNumber ?? this.emergencyContactNumber,
      reportingManager: reportingManager,
      workType: workType,
      officeLocation: officeLocation,
      shiftPolicy: shiftPolicy,
      joiningDate: joiningDate,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}