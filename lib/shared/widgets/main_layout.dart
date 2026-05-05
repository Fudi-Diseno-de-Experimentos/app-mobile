import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        type: BottomNavigationBarType.fixed,
        items: [
          _buildNavItem('assets/icons/home-icon.svg', 'Home', 0),
          _buildNavItem('assets/icons/file-icon.svg', 'Files', 1),
          _buildNavItem('assets/icons/message-square-icon.svg', 'Messages', 2),
          _buildNavItem('assets/icons/user-icon.svg', 'Profile', 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String asset, String label, int index) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      ),
      activeIcon: SvgPicture.asset(
        asset,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
      ),
      label: label,
    );
  }
}
