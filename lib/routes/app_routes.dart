/// All route names used in the EdoxLibrary application.
class XRoutes {
  XRoutes._();

  // --- Auth ---
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';

  // --- Main ---
  static const navigation = '/';
  static const dashboard = '/dashboard';

  // --- Members ---
  static const members = '/members';
  static const memberDetail = '/member-detail';
  static const addMember = '/add-member';
  static const editMember = '/edit-member';

  // --- Seats ---
  static const seats = '/seats';
  static const seatDetail = '/seat-detail';
  static const manageSeats = '/manage-seats';

  // --- Payments ---
  static const payments = '/payments';
  static const collectPayment = '/collect-payment';

  // --- Plans ---
  static const plans = '/plans';
  static const addPlan = '/add-plan';

  // --- Reminders ---
  static const reminders = '/reminders';

  // --- Settings ---
  static const settings = '/settings';

  // --- Subscription ---
  static const subscription = '/subscription';
}
