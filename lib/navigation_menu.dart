import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/features/dashboard/screens/dashboard_screen.dart';
import 'package:edox_library/features/members/screens/members_list/members_list_screen.dart';
import 'package:edox_library/features/seats/screens/seats_overview/seats_overview_screen.dart';
import 'package:edox_library/features/settings/screens/settings_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = XHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: XSizes.navBarHeight,
          elevation: 3,
          selectedIndex: controller.selectedIndex.value,
          backgroundColor: dark ? XColors.darkBackground : XColors.white,
          indicatorColor: XColors.primary.withValues(alpha: 0.1),
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.home),
              selectedIcon: Icon(Iconsax.home_15),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.people),
              selectedIcon: Icon(Iconsax.people5),
              label: 'Members',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.grid_2),
              selectedIcon: Icon(Iconsax.grid_25),
              label: 'Seats',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.setting_2),
              selectedIcon: Icon(Iconsax.setting_25),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final screens = [
    const DashboardScreen(),
    const MembersListScreen(),
    const SeatsOverviewScreen(),
    const SettingsScreen(),
  ];
}
