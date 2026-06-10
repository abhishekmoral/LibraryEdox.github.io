import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:edox_library/utils/constants/colors.dart';
import 'package:edox_library/utils/constants/sizes.dart';
import 'package:edox_library/utils/helpers/helper_function.dart';
import 'package:edox_library/features/dashboard/screens/dashboard_screen.dart';
import 'package:edox_library/features/members/screens/members_list/members_list_screen.dart';
import 'package:edox_library/features/seats/screens/seats_overview/seats_overview_screen.dart';
import 'package:edox_library/features/settings/screens/settings_screen.dart';

class TabChangeNotification extends Notification {
  final int index;
  TabChangeNotification(this.index);
}

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MembersListScreen(),
    SeatsOverviewScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = XHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: NotificationListener<TabChangeNotification>(
        onNotification: (notification) {
          setState(() {
            _selectedIndex = notification.index;
          });
          return true;
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        height: XSizes.navBarHeight,
        elevation: 3,
        selectedIndex: _selectedIndex,
        backgroundColor: dark ? XColors.darkBackground : XColors.white,
        indicatorColor: XColors.primary.withValues(alpha: 0.1),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
    );
  }
}
