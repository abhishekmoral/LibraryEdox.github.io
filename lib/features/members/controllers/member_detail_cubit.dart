import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/features/payments/models/payment_model.dart';

abstract class MemberDetailState {}

class MemberDetailInitial extends MemberDetailState {}

class MemberDetailActionLoading extends MemberDetailState {}

class MemberDetailActionSuccess extends MemberDetailState {
  final String message;
  MemberDetailActionSuccess(this.message);
}

class MemberDetailActionFailure extends MemberDetailState {
  final String error;
  MemberDetailActionFailure(this.error);
}

class MemberDetailCubit extends Cubit<MemberDetailState> {
  final _memberRepository = MemberRepository.instance;
  final _activityRepository = ActivityRepository.instance;

  MemberDetailCubit() : super(MemberDetailInitial());

  Future<void> deleteMember(MemberModel member) async {
    emit(MemberDetailActionLoading());
    try {
      await _memberRepository.deleteMember(member.id);

      final activity = ActivityModel(
        id: '',
        type: 'member',
        title: 'Member Deleted',
        description: '${member.fullName} was removed',
        memberId: member.id,
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      emit(MemberDetailActionSuccess('Member deleted successfully.'));
    } catch (e) {
      emit(MemberDetailActionFailure(e.toString()));
    }
  }

  Future<void> renewMembership(MemberModel member, DateTime newExpiry, double fee) async {
    emit(MemberDetailActionLoading());
    try {
      final updatedMember = member.copyWith(
        expiryDate: newExpiry,
        planId: 'manual',
        planName: 'Manual Plan',
        status: 'active',
        updatedAt: DateTime.now(),
      );

      await _memberRepository.updateMember(updatedMember);

      final payment = PaymentModel(
        id: '',
        memberId: member.id,
        memberName: member.fullName,
        amount: fee,
        paymentMethod: 'cash',
        type: 'renewal',
        slotId: member.slotId,
        date: DateTime.now(),
        planId: 'manual',
        planName: 'Manual Plan',
        notes: 'Membership Renewal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await PaymentRepository.instance.savePaymentRecord(payment);

      final activity = ActivityModel(
        id: '',
        type: 'member',
        title: 'Membership Renewed',
        description: '${member.fullName} renewed membership',
        memberId: member.id,
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      emit(MemberDetailActionSuccess('Membership renewed successfully!'));
    } catch (e) {
      emit(MemberDetailActionFailure(e.toString()));
    }
  }
}
