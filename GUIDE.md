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

## 5. User Profile
**File:** [`lib/features/profile/presentation/providers/user_profile_provider.dart`](lib/features/profile/presentation/providers/user_profile_provider.dart)

The Profile screen is populated by `_kDummyProfile`:
- **User:** **Rahul Sharma (EMP-2024-0187)**.
- **Details:** Engineering, Software Engineer II, Active status.
- **Manager:** Priya Sharma.

---

## 6. Leave Management
**File:** [`lib/features/leaves/data/repositories/dummy_leave_repository.dart`](lib/features/leaves/data/repositories/dummy_leave_repository.dart)

- **Balances:** CL (2), Short Leave (3), Late Mark (2).
- **History:** 3 hardcoded entries for **EMP-1042** (Personal work, Doctor appointment, Early exit).

---

## 7. Timesheet
**File:** [`lib/features/timesheet/data/repositories/timesheet_repository.dart`](lib/features/timesheet/data/repositories/timesheet_repository.dart)

- **Seeded Data:** Automatically populates entries for Mon-Thu of the current week (Development, Meetings, Training).
- **Projects:** Hardcoded list in `kTimesheetProjects` (CraftEdge Mobile App, Internal Operations, etc.).

---

## 8. Hardcoded Manager List
If you need to change manager names globally, they are hardcoded in these locations:
- **Priya Sharma:** `checkin_repository.dart`, `user_profile_provider.dart`, `checkin_success_screen.dart`.
- **Arvind Joshi:** `check_out_repository.dart`, `check_out_exception_screen.dart`.
- **Jai Prakash:** `shortLeave_apply_screen.dart`.
- **Anjali Sharma:** `auth_remote_data_source.dart`.

---

## 9. Common Hardcoded IDs
- `EMP001`: Default dashboard user.
- `EMP-1042`: Used in attendance history and leave history.
- `EMP-2024-0187`: Used in user profile.
- `EMP-1001`: Used in remote auth fallback.
