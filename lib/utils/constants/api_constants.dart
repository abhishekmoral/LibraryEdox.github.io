/// External API base URL constants used throughout the EdoxLibrary application.
class ApiConstants {
  ApiConstants._();

  // ──────────────────────────────────────────────
  // SMS Providers
  // ──────────────────────────────────────────────
  static const String fast2smsBaseUrl =
      'https://www.fast2sms.com/dev/bulkV2';
  static const String twilioBaseUrl =
      'https://api.twilio.com/2010-04-01';
  static const String msg91BaseUrl =
      'https://api.msg91.com/api/v5';

  // ──────────────────────────────────────────────
  // WhatsApp
  // ──────────────────────────────────────────────
  static const String whatsappBaseUrl = 'https://wa.me/';
}
