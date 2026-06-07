import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final bool whatsappEnabled;
  final bool smsEnabled;
  final String smsProvider;
  final String smsApiKey;
  final List<int> reminderDays;
  final bool autoReminder;
  final String welcomeMessage;
  final String expiryMessage;
  final String renewalMessage;
  final String seatAllocationMessage;
  final DateTime updatedAt;

  const SettingsModel({
    required this.whatsappEnabled,
    required this.smsEnabled,
    required this.smsProvider,
    required this.smsApiKey,
    required this.reminderDays,
    required this.autoReminder,
    required this.welcomeMessage,
    required this.expiryMessage,
    required this.renewalMessage,
    required this.seatAllocationMessage,
    required this.updatedAt,
  });

  /// Create an empty [SettingsModel] with sensible defaults and template messages.
  static SettingsModel empty() => SettingsModel(
        whatsappEnabled: false,
        smsEnabled: false,
        smsProvider: 'msg91',
        smsApiKey: '',
        reminderDays: const [7, 5, 3, 1, 0],
        autoReminder: false,
        welcomeMessage:
            'Welcome {memberName}! Your seat {seatNumber} has been assigned. Your membership is valid till {expiryDate}.',
        expiryMessage:
            'Hi {memberName}, your membership is expiring on {expiryDate}. Please renew to continue using seat {seatNumber}.',
        renewalMessage:
            'Hi {memberName}, your membership has been renewed successfully! New expiry date: {expiryDate}.',
        seatAllocationMessage:
            'Hi {memberName}, seat {seatNumber} has been allocated to you. Enjoy your study time!',
        updatedAt: DateTime.now(),
      );

  /// Create a [SettingsModel] from a Firestore document snapshot.
  factory SettingsModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return SettingsModel(
      whatsappEnabled: data?['whatsappEnabled'] ?? false,
      smsEnabled: data?['smsEnabled'] ?? false,
      smsProvider: data?['smsProvider'] ?? 'msg91',
      smsApiKey: data?['smsApiKey'] ?? '',
      reminderDays: List<int>.from(data?['reminderDays'] ?? [7, 5, 3, 1, 0]),
      autoReminder: data?['autoReminder'] ?? false,
      welcomeMessage: data?['welcomeMessage'] ??
          'Welcome {memberName}! Your seat {seatNumber} has been assigned. Your membership is valid till {expiryDate}.',
      expiryMessage: data?['expiryMessage'] ??
          'Hi {memberName}, your membership is expiring on {expiryDate}. Please renew to continue using seat {seatNumber}.',
      renewalMessage: data?['renewalMessage'] ??
          'Hi {memberName}, your membership has been renewed successfully! New expiry date: {expiryDate}.',
      seatAllocationMessage: data?['seatAllocationMessage'] ??
          'Hi {memberName}, seat {seatNumber} has been allocated to you. Enjoy your study time!',
      updatedAt:
          (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the [SettingsModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'whatsappEnabled': whatsappEnabled,
        'smsEnabled': smsEnabled,
        'smsProvider': smsProvider,
        'smsApiKey': smsApiKey,
        'reminderDays': reminderDays,
        'autoReminder': autoReminder,
        'welcomeMessage': welcomeMessage,
        'expiryMessage': expiryMessage,
        'renewalMessage': renewalMessage,
        'seatAllocationMessage': seatAllocationMessage,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  /// Create a copy of this [SettingsModel] with the given fields replaced.
  SettingsModel copyWith({
    bool? whatsappEnabled,
    bool? smsEnabled,
    String? smsProvider,
    String? smsApiKey,
    List<int>? reminderDays,
    bool? autoReminder,
    String? welcomeMessage,
    String? expiryMessage,
    String? renewalMessage,
    String? seatAllocationMessage,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      smsProvider: smsProvider ?? this.smsProvider,
      smsApiKey: smsApiKey ?? this.smsApiKey,
      reminderDays: reminderDays ?? this.reminderDays,
      autoReminder: autoReminder ?? this.autoReminder,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      expiryMessage: expiryMessage ?? this.expiryMessage,
      renewalMessage: renewalMessage ?? this.renewalMessage,
      seatAllocationMessage:
          seatAllocationMessage ?? this.seatAllocationMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
