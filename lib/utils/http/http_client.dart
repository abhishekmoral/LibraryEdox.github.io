import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:edox_library/utils/logging/logger.dart';

/// A lightweight HTTP helper with static `get` and `post` methods.
///
/// All responses are automatically decoded from JSON. Errors are logged and
/// rethrown so callers can handle them appropriately.
class XHttpHelper {
  XHttpHelper._();

  // ──────────────────────────── GET ──────────────────────────────

  /// Sends an HTTP GET request to [url] and returns the decoded JSON body.
  ///
  /// Optional [headers] are merged with the default `Content-Type: application/json`.
  /// Throws an [Exception] when the response status code is not in the 2xx range.
  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      XLoggerHelper.info('HTTP GET → $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _buildHeaders(headers),
      );

      return _handleResponse(response);
    } catch (e, st) {
      XLoggerHelper.error('HTTP GET failed: $url', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── POST ─────────────────────────────

  /// Sends an HTTP POST request to [url] with the given [body] and returns
  /// the decoded JSON body.
  ///
  /// [body] is automatically encoded to JSON when it is a [Map] or [List].
  /// Optional [headers] are merged with the default `Content-Type: application/json`.
  /// Throws an [Exception] when the response status code is not in the 2xx range.
  static Future<Map<String, dynamic>> post(
    String url,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    try {
      XLoggerHelper.info('HTTP POST → $url');

      final response = await http.post(
        Uri.parse(url),
        headers: _buildHeaders(headers),
        body: body is String ? body : jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e, st) {
      XLoggerHelper.error('HTTP POST failed: $url', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── Internal ─────────────────────────

  /// Merges caller-provided headers with defaults.
  static Map<String, String> _buildHeaders(Map<String, String>? custom) {
    final defaults = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (custom != null) defaults.addAll(custom);
    return defaults;
  }

  /// Checks the HTTP status code and decodes the response body.
  static Map<String, dynamic> _handleResponse(http.Response response) {
    XLoggerHelper.info('HTTP ${response.statusCode} ← ${response.request?.url}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      // Wrap non-map bodies so the return type is consistent.
      return <String, dynamic>{'data': decoded};
    }

    // Non-success status codes
    final errorBody = response.body.isNotEmpty ? response.body : 'No response body';
    XLoggerHelper.error('HTTP error ${response.statusCode}: $errorBody');
    throw Exception('Request failed with status ${response.statusCode}: $errorBody');
  }
}
