import 'package:get/get.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/seats/seat_repository.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/dashboard/models/dashboard_stats_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';

class DashboardController extends GetxController {
  static DashboardController get instance => Get.find();

  final isLoading = false.obs;
  Rx<DashboardStatsModel> stats = DashboardStatsModel.empty().obs;
  RxList<ActivityModel> recentActivity = <ActivityModel>[].obs;
  RxList<double> revenueChartData = List.filled(6, 0.0).obs;

  final _memberRepo = Get.put(MemberRepository());
  final _seatRepo = Get.put(SeatRepository());
  final _paymentRepo = Get.put(PaymentRepository());
  final _activityRepo = Get.put(ActivityRepository());

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    recentActivity.bindStream(_activityRepo.getRecentActivityStream());
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;

      // Fetch all required stats concurrently
      final responses = await Future.wait([
        _memberRepo.getTotalMembersCount(),
        _memberRepo.getActiveMembersCount(),
        _seatRepo.getTotalSeatsCount(),
        _seatRepo.getAvailableSeatsCount(),
        _seatRepo.getOccupiedSeatsCount(),
        _paymentRepo.getMonthlyRevenue(),
        _paymentRepo.getTodaysCollection(),
        _memberRepo.getPendingPaymentsAmount(),
        _paymentRepo.getRevenueChartData(),
      ]);

      // Map responses to variables
      final totalMembers = responses[0] as int;
      final activeMembers = responses[1] as int;
      final totalSeats = responses[2] as int;
      final availableSeats = responses[3] as int;
      final occupiedSeats = responses[4] as int;
      final monthlyRevenue = responses[5] as double;
      final todaysCollection = responses[6] as double;
      final pendingPaymentsAmount = responses[7] as double;
      final chartDataList = responses[8] as List<double>;

      revenueChartData.value = chartDataList;

      // The rest of the fields can be computed or mocked for now 
      // (e.g. pending payments, expired members)
      final expiredMembers = totalMembers - activeMembers;
      final expiringSoon = 0; 
      final pendingPayments = pendingPaymentsAmount.toInt();

      stats.value = DashboardStatsModel(
        totalMembers: totalMembers,
        activeMembers: activeMembers,
        expiredMembers: expiredMembers,
        expiringSoon: expiringSoon,
        totalSeats: totalSeats,
        availableSeats: availableSeats,
        occupiedSeats: occupiedSeats,
        pendingPayments: pendingPayments,
        monthlyRevenue: monthlyRevenue,
        todaysCollection: todaysCollection,
      );
    } catch (e) {
      print('DASHBOARD ERROR: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
