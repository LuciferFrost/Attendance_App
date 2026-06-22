import 'package:demo4/features/attendance/data/models/check_out_exception.dart';
import 'package:demo4/features/attendance/data/repositories/check_out_exception_repository.dart';
import 'package:demo4/features/attendance/presentation/controllers/check_out_exception_controller.dart';
import 'package:riverpod/riverpod.dart';

/// Repository provider for check-out exception
final checkOutExceptionRepositoryProvider = Provider((ref) {
  return CheckOutExceptionRepository();
});

/// Controller provider for managing check-out exception submission
final checkOutExceptionControllerProvider =
NotifierProvider<CheckOutExceptionController, AsyncValue<CheckOutExceptionResponse?>>(
      () => CheckOutExceptionController(),
);