import 'package:flutter/material.dart';
import 'package:flutter_widgets/screens/calculator_screen/calculator_screen.dart';
import 'package:flutter_widgets/screens/profile/profile_screen.dart';
import 'package:flutter_widgets/Screens/home_screen.dart';
import 'package:get/get.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    CalculatorScreen(),
    const Center(child: Text("Notification")),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B39FD).withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded, Icons.home_outlined),
            _buildNavItem(1, Icons.calculate_rounded, Icons.calculate_outlined),
            _buildNavItem(2, Icons.notifications_rounded, Icons.notifications_outlined),
            _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7B39FD).withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? const Color(0xFF7B39FD) : const Color(0xFF9CA3AF),
          size: 26,
        ),
      ),
    );
  }
}
