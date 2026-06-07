/// All enumerations used throughout the EdoxLibrary application.

/// Represents the current status of a library seat.
enum SeatStatus { available, occupied, reserved, maintenance }

/// Represents the membership status of a library member.
enum MemberStatus { active, expired, expiringSoon }

/// Represents the payment status of a fee/invoice.
enum PaymentStatus { paid, pending, overdue }

/// Represents the method used for payment.
enum PaymentMethod { cash, upi, bankTransfer }

/// Represents the gender of a member.
enum Gender { male, female, other }

/// Represents the duration of a membership plan.
enum PlanDuration { monthly, quarterly, halfYearly, annual }

/// Represents the type of notification sent to a member.
enum NotificationType {
  expiryReminder,
  feeDue,
  renewal,
  welcome,
  seatAllocation,
}

/// Represents the channel used to send a notification.
enum NotificationChannel { whatsapp, sms }

/// Represents the delivery status of a notification.
enum NotificationStatus { sent, failed, pending }

/// Represents the type of activity logged in the system.
enum ActivityType {
  memberAdded,
  memberRemoved,
  membershipRenewed,
  seatAssigned,
  seatChanged,
  seatVacated,
  paymentCollected,
  planCreated,
}

/// Represents the subscription plan tier of a library owner.
enum SubscriptionPlan { trial, basic, premium }

/// Represents the current status of a subscription.
enum SubscriptionStatus { active, expired, cancelled }

/// Represents the billing cycle for a subscription.
enum BillingCycle { monthly, yearly }

/// Represents the SMS provider used for sending SMS notifications.
enum SMSProvider { msg91, twilio, fast2sms }

/// Represents the view type for displaying items (grid or list).
enum ViewType { grid, list }
