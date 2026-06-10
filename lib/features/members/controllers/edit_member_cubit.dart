import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/utils/constants/colors.dart';

class EditMemberState {
  final bool isLoading;
  final String seatId;

  EditMemberState({required this.isLoading, required this.seatId});

  EditMemberState copyWith({bool? isLoading, String? seatId}) {
    return EditMemberState(
      isLoading: isLoading ?? this.isLoading,
      seatId: seatId ?? this.seatId,
    );
  }
}

class EditMemberCubit extends Cubit<EditMemberState> {
  final _memberRepository = MemberRepository.instance;
  final _activityRepository = ActivityRepository.instance;
  
  late MemberModel originalMember;

  EditMemberCubit() : super(EditMemberState(isLoading: false, seatId: ''));

  void initMemberData(MemberModel member) {
    originalMember = member;
    emit(EditMemberState(isLoading: false, seatId: member.seatId));
  }

  void setSeatId(String seatId) => emit(state.copyWith(seatId: seatId));

  Future<void> saveChanges(
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
      final updatedMember = originalMember.copyWith(
        fullName: fullName.trim(),
        mobile: mobile.trim(),
        alternateMobile: alternateMobile.trim(),
        email: email.trim(),
        address: address.trim(),
        notes: notes.trim(),
        seatId: state.seatId,
        seatNumber: state.seatId.isNotEmpty ? state.seatId : 'Unassigned',
        updatedAt: DateTime.now(),
      );

      await _memberRepository.updateMember(updatedMember);

      final activity = ActivityModel(
        id: '',
        type: 'member',
        title: 'Member Profile Updated',
        description: '${updatedMember.fullName} updated their profile',
        memberId: updatedMember.id,
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      Navigator.pop(context); // Pop edit screen
      Navigator.pop(context); // Pop detail screen to refresh

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member details updated successfully!'),
          backgroundColor: XColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating member: $e'),
          backgroundColor: XColors.error,
        ),
      );
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
