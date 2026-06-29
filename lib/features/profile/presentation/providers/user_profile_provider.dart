import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:demo4/features/profile/data/models/user_profile_model.dart';

const _kDummyProfile = UserProfileModel(
  name: 'Rahul Sharma',
  employeeCode: 'EMP-2024-0187',
  department: 'Engineering',
  designation: 'Software Engineer II',
  role: 'Employee',
  dateOfBirth: '14 Mar 1998',
  employeeStatus: 'Active',
  workEmail: 'rahul.sharma@craftedge.com',
  personalEmail: 'rahul.s98@gmail.com',
  contactNumber: '+91 98765 43210',
  whatsappNumber: 'Same as Contact',
  address: 'B-204, Lake View Apartments, Sec 62, Noida, UP – 201301',
  emergencyContactName: 'Anita Sharma',
  emergencyContactNumber: '+91 98123 45678',
  reportingManager: 'Priya Sharma',
  workType: 'WFO',
  officeLocation: 'Noida – Sector 62',
  shiftPolicy: 'Morning shift',
  joiningDate: '3 Jun 2024',
);

class UserProfileNotifier extends Notifier<UserProfileModel> {
  @override
  UserProfileModel build() {
    return _kDummyProfile;
  }

  void updateProfile(UserProfileModel updatedProfile) {
    state = updatedProfile;
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileModel>(
  UserProfileNotifier.new,
);
