import 'dart:convert';

import 'package:edox_library/utils/http/http_client.dart';
import 'package:edox_library/utils/logging/logger.dart';

/// A static utility class for sending SMS messages through multiple
/// third-party providers (MSG91, Twilio, Fast2SMS).
class SMSService {
  SMSService._();

  // ──────────────────────────── Dispatcher ───────────────────────

  /// Sends an SMS to [phone] with [message] using the given [provider].
  ///
  /// Returns `true` on success, `false` otherwise.
  static Future<bool> sendSMS(
    String phone,
    String message, {
    required String provider,
    required String apiKey,
    String? accountSid,
    String? authToken,
    String? fromNumber,
  }) async {
    try {
      switch (provider.toLowerCase()) {
        case 'msg91':
          return await sendViaMSG91(phone, message, apiKey);
        case 'twilio':
          if (accountSid == null || authToken == null || fromNumber == null) {
            XLoggerHelper.error('Twilio requires accountSid, authToken, and fromNumber');
            return false;
          }
          return await sendViaTwilio(phone, message, accountSid, authToken, fromNumber);
        case 'fast2sms':
          return await sendViaFast2SMS(phone, message, apiKey);
        default:
          XLoggerHelper.error('Unknown SMS provider: $provider');
          return false;
      }
    } catch (e, st) {
      XLoggerHelper.error('SMS dispatch failed', error: e, stackTrace: st);
      return false;
    }
  }

  // ──────────────────────────── MSG91 ───────────────────────────

  /// Sends an SMS via the MSG91 API.
  static Future<bool> sendViaMSG91(
    String phone,
    String message,
    String apiKey,
  ) async {
    try {
      XLoggerHelper.info('Sending SMS via MSG91 to $phone');
      final response = await XHttpHelper.post(
        'https://api.msg91.com/api/v5/flow/',
        {
          'mobiles': phone,
          'message': message,
        },
        headers: {'authkey': apiKey},
      );

      final success = response['type'] == 'success';
      if (success) {
        XLoggerHelper.info('MSG91 SMS sent successfully to $phone');
      } else {
        XLoggerHelper.warning('MSG91 SMS failed: ${response['message']}');
      }
      return success;
    } catch (e, st) {
      XLoggerHelper.error('MSG91 SMS failed', error: e, stackTrace: st);
      return false;
    }
  }

  // ──────────────────────────── Twilio ───────────────────────────

  /// Sends an SMS via the Twilio API.
  static Future<bool> sendViaTwilio(
    String phone,
    String message,
    String accountSid,
    String authToken,
    String fromNumber,
  ) async {
    try {
      XLoggerHelper.info('Sending SMS via Twilio to $phone');

      final credentials = base64Encode(utf8.encode('$accountSid:$authToken'));
      final response = await XHttpHelper.post(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json',
        {
          'To': phone,
          'From': fromNumber,
          'Body': message,
        },
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      final success = response['sid'] != null;
      if (success) {
        XLoggerHelper.info('Twilio SMS sent successfully to $phone');
      } else {
        XLoggerHelper.warning('Twilio SMS failed: ${response['message']}');
      }
      return success;
    } catch (e, st) {
      XLoggerHelper.error('Twilio SMS failed', error: e, stackTrace: st);
      return false;
    }
  }

  // ──────────────────────────── Fast2SMS ─────────────────────────

  /// Sends an SMS via the Fast2SMS API.
  static Future<bool> sendViaFast2SMS(
    String phone,
    String message,
    String apiKey,
  ) async {
    try {
      XLoggerHelper.info('Sending SMS via Fast2SMS to $phone');
      final response = await XHttpHelper.post(
        'https://www.fast2sms.com/dev/bulkV2',
        {
          'message': message,
          'language': 'english',
          'route': 'q',
          'numbers': phone,
        },
        headers: {'authorization': apiKey},
      );

      final success = response['return'] == true;
      if (success) {
        XLoggerHelper.info('Fast2SMS sent successfully to $phone');
      } else {
        XLoggerHelper.warning('Fast2SMS failed: ${response['message']}');
      }
      return success;
    } catch (e, st) {
      XLoggerHelper.error('Fast2SMS failed', error: e, stackTrace: st);
      return false;
    }
  }
}
