import 'package:url_launcher/url_launcher.dart';

import 'package:edox_library/utils/logging/logger.dart';

/// A static utility class for WhatsApp messaging, phone calls,
/// and SMS via [url_launcher].
class WhatsAppService {
  WhatsAppService._();

  // ──────────────────────────── WhatsApp ─────────────────────────

  /// Opens a WhatsApp chat with [phoneNumber] pre-filled with [message].
  ///
  /// [phoneNumber] should include the country code (e.g. `919876543210`).
  static Future<void> sendMessage(String phoneNumber, String message) async {
    try {
      final url = buildWhatsAppUrl(phoneNumber, message);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        XLoggerHelper.info('WhatsApp message opened for $phoneNumber');
      } else {
        XLoggerHelper.warning('Could not launch WhatsApp for $phoneNumber');
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e, st) {
      XLoggerHelper.error('WhatsApp send failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Sends a WhatsApp message to each recipient sequentially.
  ///
  /// Each map in [recipients] must have `'phone'` and `'message'` keys.
  static Future<void> sendBulkMessages(
    List<Map<String, String>> recipients,
  ) async {
    for (final recipient in recipients) {
      final phone = recipient['phone'] ?? '';
      final message = recipient['message'] ?? '';
      if (phone.isNotEmpty) {
        await sendMessage(phone, message);
        // Small delay to prevent rapid-fire URL launches.
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  /// Builds a `wa.me` URL for the given [phone] and [message].
  static String buildWhatsAppUrl(String phone, String message) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMessage = Uri.encodeComponent(message);
    return 'https://wa.me/$cleanPhone?text=$encodedMessage';
  }

  // ──────────────────────────── Phone Call ───────────────────────

  /// Launches the phone dialer for [phoneNumber].
  static Future<void> callMember(String phoneNumber) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final uri = Uri.parse('tel:$cleanPhone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        XLoggerHelper.info('Phone call initiated for $phoneNumber');
      } else {
        XLoggerHelper.warning('Could not launch phone dialer for $phoneNumber');
        throw Exception('Could not launch phone dialer');
      }
    } catch (e, st) {
      XLoggerHelper.error('Phone call failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── SMS ──────────────────────────────

  /// Opens the SMS app pre-filled with [message] for [phoneNumber].
  static Future<void> sendSMS(String phoneNumber, String message) async {
    try {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final encodedMessage = Uri.encodeComponent(message);
      final uri = Uri.parse('sms:$cleanPhone?body=$encodedMessage');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        XLoggerHelper.info('SMS app opened for $phoneNumber');
      } else {
        XLoggerHelper.warning('Could not launch SMS app for $phoneNumber');
        throw Exception('Could not launch SMS app');
      }
    } catch (e, st) {
      XLoggerHelper.error('SMS launch failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}
