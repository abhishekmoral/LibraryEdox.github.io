import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/features/payments/models/payment_model.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/dashboard/controllers/dashboard_cubit.dart';
import 'package:edox_library/utils/constants/colors.dart';

class AddMemberState {
  final bool isLoading;
  final String gender;
  final String planId;
  final String seatId;
  final String paymentMethod;
  final String selectedSlotId;

  AddMemberState({
    required this.isLoading,
    required this.gender,
    required this.planId,
    required this.seatId,
    required this.paymentMethod,
    required this.selectedSlotId,
  });

  AddMemberState copyWith({
    bool? isLoading,
    String? gender,
    String? planId,
    String? seatId,
    String? paymentMethod,
    String? selectedSlotId,
  }) {
    return AddMemberState(
      isLoading: isLoading ?? this.isLoading,
      gender: gender ?? this.gender,
      planId: planId ?? this.planId,
      seatId: seatId ?? this.seatId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      selectedSlotId: selectedSlotId ?? this.selectedSlotId,
    );
  }
}

class AddMemberCubit extends Cubit<AddMemberState> {
  final _memberRepository = MemberRepository.instance;
  final _activityRepository = ActivityRepository.instance;
  final _paymentRepository = PaymentRepository.instance;

  AddMemberCubit() : super(AddMemberState(
    isLoading: false,
    gender: 'male',
    planId: 'monthly',
    seatId: '',
    paymentMethod: 'cash',
    selectedSlotId: 'default',
  )) {
    final activeSlotId = locator<SlotsCubit>().state.selectedSlotId;
    emit(state.copyWith(selectedSlotId: activeSlotId == 'all' ? 'default' : activeSlotId));
  }

  void setGender(String gender) => emit(state.copyWith(gender: gender));
  void setPlanId(String planId) => emit(state.copyWith(planId: planId));
  void setSeatId(String seatId) => emit(state.copyWith(seatId: seatId));
  void setPaymentMethod(String paymentMethod) => emit(state.copyWith(paymentMethod: paymentMethod));
  void setSelectedSlotId(String slotId) => emit(state.copyWith(selectedSlotId: slotId, seatId: ''));

  Future<void> saveMember(
    BuildContext context, {
    required String fullName,
    required String mobile,
    required String alternateMobile,
    required String email,
    required String address,
    required String notes,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      DateTime expiryDate = DateTime.now();
      String planName = 'Monthly';
      if (state.planId == 'quarterly') {
        expiryDate = DateTime.now().add(const Duration(days: 90));
        planName = 'Quarterly';
      } else if (state.planId == 'half_yearly') {
        expiryDate = DateTime.now().add(const Duration(days: 180));
        planName = 'Half Yearly';
      } else if (state.planId == 'annual') {
        expiryDate = DateTime.now().add(const Duration(days: 365));
        planName = 'Annual';
      } else {
        expiryDate = DateTime.now().add(const Duration(days: 30));
      }

      final newMember = MemberModel(
        id: '',
        fullName: fullName.trim(),
        mobile: mobile.trim(),
        alternateMobile: alternateMobile.trim(),
        email: email.trim(),
        address: address.trim(),
        gender: state.gender,
        photo: '',
        seatId: state.seatId,
        seatNumber: state.seatId.isNotEmpty ? state.seatId : 'Unassigned',
        slotId: state.selectedSlotId,
        joiningDate: DateTime.now(),
        planId: state.planId,
        planName: planName,
        expiryDate: expiryDate,
        paymentStatus: 'paid',
        status: 'active',
        notes: notes.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final memberId = await _memberRepository.saveMemberRecord(newMember);

      double amountPaid = 0.0;
      if (state.planId == 'monthly') amountPaid = 1500;
      else if (state.planId == 'quarterly') amountPaid = 4000;
      else if (state.planId == 'half_yearly') amountPaid = 7500;
      else if (state.planId == 'annual') amountPaid = 14000;

      final payment = PaymentModel(
        id: '',
        memberId: memberId,
        memberName: fullName.trim(),
        amount: amountPaid,
        paymentMethod: state.paymentMethod,
        type: 'new',
        slotId: state.selectedSlotId,
        date: DateTime.now(),
        planId: state.planId,
        planName: planName,
        notes: notes.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _paymentRepository.savePaymentRecord(payment);

      final activity = ActivityModel(
        id: '',
        type: 'member',
        title: 'New Member Added',
        description: '${fullName.trim()} joined the library',
        memberId: memberId,
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      if (locator.isRegistered<DashboardCubit>()) {
        locator<DashboardCubit>().fetchDashboardData();
      }

      Navigator.pop(context); // Go back

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member added successfully!'),
          backgroundColor: XColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding member: $e'),
          backgroundColor: XColors.error,
        ),
      );
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
