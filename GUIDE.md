# Development Guide: Mock Data & Configurations

This project uses dummy data and mock repositories to facilitate UI development and testing without requiring a live backend. This guide lists all major sources of mock data and how to modify or replace them with real API integrations.

---

## 1. Authentication & Session
- **Repository:** [`lib/features/auth/data/datasources/dummy_auth_repository.dart`](lib/features/auth/data/datasources/dummy_auth_repository.dart)
    - **Credentials:** `admin@craftedge.local` / `password`.
    - **Token:** `dummy_jwt_token_xyz123`.
- **Remote Data Source (Fallback):** [`lib/features/auth/data/datasources/auth_remote_data_source.dart`](lib/features/auth/data/datasources/auth_remote_data_source.dart)
    - Returns **Anjali Sharma (EMP-1001)** when base URL contains "local".
- **Hardcoded Token:** [`lib/features/auth/data/repositories/auth_repository_impl.dart`](lib/features/auth/data/repositories/auth_repository_impl.dart)
    - Manually writes `sample-token` to secure storage on login.

---

## 2. Dashboard & Global State
**File:** [`lib/features/dashboard/presentation/providers/dashboard_providers.dart`](lib/features/dashboard/presentation/providers/dashboard_providers.dart)

The `DashboardNotifier` provides the initial application state:
- **`isManager` Flag:** Set to `true` by default. Flip to `false` to hide the Manager Overview section on the home screen.
- **Mock User:** **Admin (EMP001)**.
- **Static Date:** `Wed, 12 Jun 2024`.
- **Initial Progress:** `65.0%` (5.2 / 8 hours worked).

---

## 3. Geolocation & Geofencing
**File:** [`lib/features/attendance/data/data_sources/dummy_geolocation.dart`](lib/features/attendance/data/data_sources/dummy_geolocation.dart)

- **Office Locations:** `mainOffice` (Noida Sec 62), `gurgaonOffice`, `bangaloreOffice`.
- **Simulated Positions:** `userAtOffice`, `userNearOffice`, `userFarFromOffice`.

**File:** [`lib/features/attendance/data/data_sources/geolocation_service.dart`](lib/features/attendance/data/data_sources/geolocation_service.dart)
- **Override:** `getCurrentLocation()` is hardcoded to return `DummyGeolocation.userFarFromOffice`. Change this to `userNearOffice` to test successful check-in without moving.

---

## 4. Attendance & Check-In
### Repositories
- **Check-In:** [`lib/features/attendance/data/repositories/checkin_repository.dart`](lib/features/attendance/data/repositories/checkin_repository.dart)
    - **Holiday Check:** `getTodayHolidayInfo()` returns `_dummyHoliday` (Priya Sharma). Return `null` to bypass.
- **Check-Out:** [`lib/features/attendance/data/repositories/check_out_repository.dart`](lib/features/attendance/data/repositories/check_out_repository.dart)
    - Returns **Arvind Joshi** as the default manager for exceptions.
- **Check-Out Exception:** [`lib/features/attendance/data/repositories/check_out_exception_repository.dart`](lib/features/attendance/data/repositories/check_out_exception_repository.dart)
    - Returns **Harsh Singh** as the manager.

### History & Correction
- **Attendance History:** [`lib/features/attendance_dashboard/presentation/providers/attendance_history_providers.dart`](lib/features/attendance_dashboard/presentation/providers/attendance_history_providers.dart)
    - Uses **EMP-1042** for history entries.
- **Attendance Correction:** [`lib/features/attendance_dashboard/presentation/screens/attendance_correction_screen.dart`](lib/features/attendance_dashboard/presentation/screens/attendance_correction_screen.dart)
    - Hardcoded manager name: **Priya Sharma**.

### Success Screens
- **Check-In Success:** [`lib/features/attendance/presentation/screens/checkin_success_screen.dart`](lib/features/attendance/presentation/screens/checkin_success_screen.dart)
    - **Hardcoded Employee:** `Rahul Kumar . EMP-1042` (Line 385).
    - **Approval Info:** `Priya Sharma (Manager)` on `1 Jun 2025`.
- **Check-Out Success:** [`lib/features/attendance/presentation/providers/checkout_providers.dart`](lib/features/attendance/presentation/providers/checkout_providers.dart)
    - Hardcoded summary: 9:04 AM - 6:32 PM, 8.2 / 9.0 hours logged.

### Logic Toggles
- **Work Reason Pre-approval:** [`lib/features/attendance/presentation/screens/workReason_screen.dart`](lib/features/attendance/presentation/screens/workReason_screen.dart)
    - `isPreApproved`: Set to `true`. Toggle to `false` to see the "Approval Pending" modal.

---

## 5. Manager Overview (Approvals & Team)
The following screens in `lib/features/manager/presentation/screens/` use dummy data:

- **Attendance Exceptions:** `attendance_exception_screen.dart`
    - Dummy requests for **Aditya Kumar (EMP-0042)**.
- **Regularization:** `regularization_screen.dart`
    - "Missed check-in" requests for **Aditya Kumar (EMP-0042)**.
- **Leave Approvals:** `leave_approvals_screen.dart`
    - Leave requests for **Aditya Kumar (EMP-0042)**.
- **Timesheet Approvals:** `timesheet_approvals_screen.dart`
    - Weekly logs for **Aditya Kumar**, **Siddharth Roy**, **Ishita Jain**, **Rohan Mehta**, **Ananya Singh**.
- **Team Attendance:** `team_attendance_screen.dart`
    - Static list of 5+ employees (Arjun, Sneha, Vikram, etc.) with hardcoded statuses.

---

## 6. User Profile
**File:** [`lib/features/profile/presentation/providers/user_profile_provider.dart`](lib/features/profile/presentation/providers/user_profile_provider.dart)

The Profile screen is populated by `_kDummyProfile`:
- **User:** **Rahul Sharma (EMP-2024-0187)**.
- **Details:** Engineering, Software Engineer II, Active status.
- **Manager:** Priya Sharma.

---

## 7. Leave Management
**File:** [`lib/features/leaves/data/repositories/dummy_leave_repository.dart`](lib/features/leaves/data/repositories/dummy_leave_repository.dart)

- **Balances:** CL (2), Short Leave (3), Late Mark (2).
- **History:** 3 hardcoded entries for **EMP-1042** (Personal work, Doctor appointment, Early exit).

---

## 8. Timesheet
**File:** [`lib/features/timesheet/data/repositories/timesheet_repository.dart`](lib/features/timesheet/data/repositories/timesheet_repository.dart)

- **Seeded Data:** Automatically populates entries for Mon-Thu of the current week (Development, Meetings, Training).
- **Projects:** Hardcoded list in `kTimesheetProjects` (CraftEdge Mobile App, Internal Operations, etc.).

---

## 9. Hardcoded Manager List
If you need to change manager names globally, they are hardcoded in these locations:
- **Priya Sharma:** `checkin_repository.dart`, `user_profile_provider.dart`, `checkin_success_screen.dart`, `attendance_correction_screen.dart`.
- **Arvind Joshi:** `check_out_repository.dart`, `check_out_exception_screen.dart`.
- **Jai Prakash:** `shortLeave_apply_screen.dart`.
- **Anjali Sharma:** `auth_remote_data_source.dart`.
- **Harsh Singh:** `check_out_exception_repository.dart`.

---

## 10. Common Hardcoded IDs
- `EMP001`: Default dashboard user.
- `EMP-1042`: Used in attendance history and leave history.
- `EMP-2024-0187`: Used in user profile.
- `EMP-1001`: Used in remote auth fallback.
- `EMP-0042`, `EMP-0031`, `EMP-0078`, `EMP-0055`, `EMP-0019`: Used in manager approval flows.
