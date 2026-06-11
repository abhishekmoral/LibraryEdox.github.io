import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/slots/slot_repository.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';
import 'package:edox_library/features/seats/controllers/seats_cubit.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';
import 'package:edox_library/utils/constants/colors.dart';

class SlotsState {
  final List<SlotModel> slots;
  final SlotModel selectedSlot;

  SlotsState({required this.slots, required this.selectedSlot});

  String get selectedSlotId => selectedSlot.id;
}

class SlotsCubit extends Cubit<SlotsState> {
  final _slotRepo = SlotRepository.instance;
  StreamSubscription<List<SlotModel>>? _slotsSubscription;
  StreamSubscription<User?>? _authSubscription;

  SlotsCubit() : super(SlotsState(
    slots: [],
    selectedSlot: SlotModel(
      id: 'default',
      name: 'Complete Shift',
      startTime: '12:00 AM',
      endTime: '11:59 PM',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  )) {
    _init();
  }

  Future<void> _syncPredefinedSlots(List<SlotModel> loadedSlots) async {
    final predefined = [
      {'name': 'Complete Shift', 'start': '12:00 AM', 'end': '11:59 PM'},
      {'name': 'Morning Shift', 'start': '07:00 AM', 'end': '02:00 PM'},
      {'name': 'Evening Shift', 'start': '02:00 PM', 'end': '09:00 PM'},
      {'name': 'Day Shift', 'start': '07:00 AM', 'end': '09:00 PM'},
      {'name': 'Night Shift', 'start': '09:00 PM', 'end': '07:00 AM'},
    ];
    final predefinedNames = predefined.map((p) => p['name']!).toSet();
    final seenNames = <String>{};

    // 1. Delete any slot that is not in the predefined list OR is a duplicate of a predefined name
    for (final slot in loadedSlots) {
      if (!predefinedNames.contains(slot.name) || seenNames.contains(slot.name)) {
        await _slotRepo.deleteSlot(slot.id);
      } else {
        seenNames.add(slot.name);
      }
    }

    // 2. Add any missing predefined slots
    for (final p in predefined) {
      if (!seenNames.contains(p['name'])) {
        final String docId = p['name'] == 'Complete Shift' ? 'default' : '';
        final newSlot = SlotModel(
          id: docId,
          name: p['name']!,
          startTime: p['start']!,
          endTime: p['end']!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        if (docId == 'default') {
          await _slotRepo.saveSlotRecordWithId('default', newSlot);
        } else {
          await _slotRepo.saveSlotRecord(newSlot);
        }
      }
    }
  }

  void _init() {
    _authSubscription = AuthenticationRepository.instance.authStateChanges.listen((user) {
      if (user != null) {
        _slotsSubscription?.cancel();
        _slotsSubscription = _slotRepo.getSlotsStream().listen((loadedSlots) async {
          final predefinedNames = {
            'Complete Shift',
            'Morning Shift',
            'Day Shift',
            'Evening Shift',
            'Night Shift',
          };
          
          final loadedNames = <String>[];
          bool hasDuplicates = false;
          for (final s in loadedSlots) {
            if (loadedNames.contains(s.name)) {
              hasDuplicates = true;
            } else {
              loadedNames.add(s.name);
            }
          }
          final loadedNamesSet = loadedNames.toSet();
          
          final hasExtra = loadedSlots.any((s) => !predefinedNames.contains(s.name));
          final hasMissing = predefinedNames.any((name) => !loadedNamesSet.contains(name));
          
          if (hasExtra || hasMissing || hasDuplicates) {
            await _syncPredefinedSlots(loadedSlots);
            return;
          }

          SlotModel nextSelected = state.selectedSlot;
          if (nextSelected.id == 'default' || !loadedSlots.any((s) => s.id == nextSelected.id)) {
            nextSelected = loadedSlots.firstWhereOrNull((s) => s.name == 'Complete Shift') ?? loadedSlots.first;
          }

          emit(SlotsState(
            slots: loadedSlots,
            selectedSlot: nextSelected,
          ));
        });
      } else {
        _slotsSubscription?.cancel();
        emit(SlotsState(
          slots: [],
          selectedSlot: SlotModel(
            id: 'default',
            name: 'Complete Shift',
            startTime: '12:00 AM',
            endTime: '11:59 PM',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ));
      }
    });
  }

  void selectSlot(SlotModel slot) {
    emit(SlotsState(slots: state.slots, selectedSlot: slot));
    
    if (locator.isRegistered<SeatsCubit>()) {
      locator<SeatsCubit>().onSelectedSlotChanged(slot.id);
    }
    if (locator.isRegistered<MembersCubit>()) {
      locator<MembersCubit>().onSelectedSlotChanged(slot.id);
    }
  }

  /// Parse a time string like "7:00 AM", "12:00 AM", "11:59 PM" into total minutes from midnight (0–1439).
  int _parseTimeToMinutes(String time) {
    final parts = time.trim().split(' ');
    final period = parts[1].toUpperCase();
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final int minute = int.parse(hm[1]);

    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else {
      if (hour != 12) hour += 12;
    }
    return hour * 60 + minute;
  }

  /// Simple overlap check for two non-wrapping ranges.
  bool _simpleOverlap(int startA, int endA, int startB, int endB) {
    return startA < endB && startB < endA;
  }

  /// Check whether two time ranges overlap, handling wrapping past midnight.
  bool _doTimesOverlap(int startA, int endA, int startB, int endB) {
    final aWraps = endA <= startA;
    final bWraps = endB <= startB;

    if (!aWraps && !bWraps) {
      return _simpleOverlap(startA, endA, startB, endB);
    }
    if (aWraps && bWraps) {
      return true;
    }
    if (aWraps) {
      return _simpleOverlap(startA, 1440, startB, endB) ||
             _simpleOverlap(0, endA, startB, endB);
    }
    return _simpleOverlap(startA, endA, startB, 1440) ||
           _simpleOverlap(startA, endA, 0, endB);
  }



  String _normalizeSlotName(String name) {
    final n = name.toLowerCase().trim();
    if (n.contains('whole') || n.contains('default') || n.contains('full') || n.contains('complete')) {
      return 'whole_day';
    }
    if (n.contains('morning')) {
      return 'morning';
    }
    if (n.contains('evening') || n.contains('eveining')) {
      return 'evening';
    }
    if (n.contains('night')) {
      return 'night';
    }
    if (n.contains('day')) {
      return 'day';
    }
    return n;
  }

  bool _getMatrixConflict(String normA, String normB) {
    if (normA == 'whole_day' || normB == 'whole_day') return true;
    if (normA == normB) return true;
    if (normA == 'day') {
      return normB == 'morning' || normB == 'evening';
    }
    if (normB == 'day') {
      return normA == 'morning' || normA == 'evening';
    }
    return false;
  }

  /// Check if two slots overlap by their names and time strings.
  bool doSlotsOverlap(String nameA, String startA, String endA, String nameB, String startB, String endB) {
    final normA = _normalizeSlotName(nameA);
    final normB = _normalizeSlotName(nameB);
    
    final standardSlots = {'whole_day', 'day', 'night', 'morning', 'evening'};
    
    if (standardSlots.contains(normA) && standardSlots.contains(normB)) {
      return _getMatrixConflict(normA, normB);
    }
    
    if (normA == 'whole_day' || normB == 'whole_day') return true;
    
    return _doTimesOverlap(
      _parseTimeToMinutes(startA), _parseTimeToMinutes(endA),
      _parseTimeToMinutes(startB), _parseTimeToMinutes(endB),
    );
  }

  void _showOverlapError(BuildContext context, String shiftA, String shiftB) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$shiftA" overlaps with "$shiftB". Shifts must not overlap.'),
        backgroundColor: XColors.error,
      ),
    );
  }

  bool checkOverlap(String startA, String endA, String startB, String endB) {
    return _doTimesOverlap(
      _parseTimeToMinutes(startA), _parseTimeToMinutes(endA),
      _parseTimeToMinutes(startB), _parseTimeToMinutes(endB),
    );
  }

  Future<bool> updateSlot(BuildContext context, SlotModel updatedSlot) async {
    final String name = updatedSlot.name;
    final String start = updatedSlot.startTime;
    final String end = updatedSlot.endTime;

    if (start == end) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time and end time cannot be the same.'),
          backgroundColor: XColors.error,
        ),
      );
      return false;
    }

    final otherSlots = state.slots.where((s) => s.id != updatedSlot.id).toList();
    final morningShift = otherSlots.firstWhereOrNull((s) => s.name == 'Morning Shift');
    final dayShift = otherSlots.firstWhereOrNull((s) => s.name == 'Day Shift');
    final eveningShift = otherSlots.firstWhereOrNull((s) => s.name == 'Evening Shift');
    final nightShift = otherSlots.firstWhereOrNull((s) => s.name == 'Night Shift');

    if (name == 'Morning Shift') {
      if (eveningShift != null && checkOverlap(start, end, eveningShift.startTime, eveningShift.endTime)) {
        _showOverlapError(context, name, eveningShift.name);
        return false;
      }
      if (nightShift != null && checkOverlap(start, end, nightShift.startTime, nightShift.endTime)) {
        _showOverlapError(context, name, nightShift.name);
        return false;
      }
    } else if (name == 'Evening Shift') {
      if (morningShift != null && checkOverlap(start, end, morningShift.startTime, morningShift.endTime)) {
        _showOverlapError(context, name, morningShift.name);
        return false;
      }
      if (nightShift != null && checkOverlap(start, end, nightShift.startTime, nightShift.endTime)) {
        _showOverlapError(context, name, nightShift.name);
        return false;
      }
    } else if (name == 'Night Shift') {
      if (morningShift != null && checkOverlap(start, end, morningShift.startTime, morningShift.endTime)) {
        _showOverlapError(context, name, morningShift.name);
        return false;
      }
      if (eveningShift != null && checkOverlap(start, end, eveningShift.startTime, eveningShift.endTime)) {
        _showOverlapError(context, name, eveningShift.name);
        return false;
      }
      if (dayShift != null && checkOverlap(start, end, dayShift.startTime, dayShift.endTime)) {
        _showOverlapError(context, name, dayShift.name);
        return false;
      }
    } else if (name == 'Day Shift') {
      if (nightShift != null && checkOverlap(start, end, nightShift.startTime, nightShift.endTime)) {
        _showOverlapError(context, name, nightShift.name);
        return false;
      }
    }

    try {
      await _slotRepo.updateSlot(updatedSlot);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shift "$name" updated successfully!')),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update shift: $e'), backgroundColor: XColors.error),
      );
      return false;
    }
  }

  @override
  Future<void> close() {
    _slotsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
