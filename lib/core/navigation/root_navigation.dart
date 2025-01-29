import 'package:flutter/material.dart';
import '../../features/dashboard/screens/machine_dashboard_screen.dart';
import '../../features/process/screens/process_list_screen.dart';
import '../../features/recipes/screens/recipe_list_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../config/route_config.dart';

class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const MachineDashboard(),
    const ProcessListScreen(),
    const RecipeListScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Home'),
            _buildNavItem(1, Icons.play_circle_outline_rounded, 'Process'),
            _buildNavItem(2, Icons.science_rounded, 'Recipe'),
            _buildNavItem(3, Icons.settings_rounded, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFF4CAF50) : Colors.grey[400],
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFF4CAF50) : Colors.grey[400],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
