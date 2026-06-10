import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';

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

  Future<void> renewMembership(MemberModel member, String selectedPlan) async {
    emit(MemberDetailActionLoading());
    try {
      DateTime newExpiry = member.expiryDate;
      if (newExpiry.isBefore(DateTime.now())) {
        newExpiry = DateTime.now();
      }
      
      String planName = 'Monthly';
      if (selectedPlan == 'quarterly') {
        newExpiry = newExpiry.add(const Duration(days: 90));
        planName = 'Quarterly';
      } else if (selectedPlan == 'half_yearly') {
        newExpiry = newExpiry.add(const Duration(days: 180));
        planName = 'Half Yearly';
      } else if (selectedPlan == 'annual') {
        newExpiry = newExpiry.add(const Duration(days: 365));
        planName = 'Annual';
      } else {
        newExpiry = newExpiry.add(const Duration(days: 30));
      }

      final updatedMember = member.copyWith(
        expiryDate: newExpiry,
        planId: selectedPlan,
        planName: planName,
        status: 'active',
        updatedAt: DateTime.now(),
      );

      await _memberRepository.updateMember(updatedMember);

      final activity = ActivityModel(
        id: '',
        type: 'member',
        title: 'Membership Renewed',
        description: '${member.fullName} renewed for $planName',
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
