import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1D4489),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icon/home.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            width: 34,
            height: 34,
          ),
          activeIcon: SvgPicture.asset(
            'assets/icon/home.svg',
            colorFilter: const ColorFilter.mode(Color(0xFF1D4489), BlendMode.srcIn),
            width: 34,
            height: 34,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icon/scanner.svg',
            width: 34,
            height: 34,
          ),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icon/setting.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            width: 34,
            height: 34,
          ),
          activeIcon: SvgPicture.asset(
            'assets/icon/setting.svg',
            colorFilter: const ColorFilter.mode(Color(0xFF1D4489), BlendMode.srcIn),
            width: 34,
            height: 34,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}