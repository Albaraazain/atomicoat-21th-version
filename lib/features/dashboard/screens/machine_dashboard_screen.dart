// lib/features/dashboard/screens/machine_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../core/auth/providers/auth_provider.dart';
import '../../../features/components/providers/component_provider.dart';
import '../../../widgets/app_drawer.dart';
import 'system_overview_screen.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/config/route_config.dart';

class MachineDashboard extends StatefulWidget {
  const MachineDashboard({super.key});

  @override
  _MachineDashboardState createState() => _MachineDashboardState();
}

class _MachineDashboardState extends State<MachineDashboard> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _logger = Logger();
  late DateTime _currentTime;
  late Timer _timer;

  final List<_DashboardTab> _tabs = [
    _DashboardTab(Icons.dashboard_rounded, 'Overview'),
    _DashboardTab(Icons.play_circle_outline_rounded, 'Process'),
    _DashboardTab(Icons.history_rounded, 'History'),
    _DashboardTab(Icons.build_rounded, 'Maintenance'),
  ];

  OverlayType _currentOverlayType = OverlayType.componentControl;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: AppDrawer(),
      body: Stack(
        children: [
          // iOS-style Status Bar Background
          Container(
            height: MediaQuery.of(context).padding.top + 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE8F5E9).withOpacity(0.8),
                  Color(0xFFE8F5E9).withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                _buildStatusCard(theme),
                _buildDiagramCard(theme),
                _buildStatusGrid(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFF5F5F5).withOpacity(0.95),
              Color(0xFFE8F5E9).withOpacity(0.2),
            ],
          ),
        ),
        child: Column(
          children: [
            // Location & Time
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 14, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.menu, color: Colors.grey[700]),
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Text(
                        'ALD System Status',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('HH:mm').format(_currentTime),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            // Status Display
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'IDLE',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Last Run: 2h ago',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ready',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // Status Icon
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // System Metrics
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Color(0xFFF5F5F5).withOpacity(0.8),
                        Color(0xFFF5F5F5).withOpacity(0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricColumn('Chamber\nPressure', '1.2e-6\nTorr'),
                      _buildMetricColumn('Chamber\nTemp', '25.3°C'),
                      _buildMetricColumn('Gas Flow\nRate', '20\nsccm'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagramCard(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'System Diagram',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.fullscreen),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SystemOverviewScreen(),
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              // ALD System Diagram
              Container(
                height: 280,
                margin: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    // Background Diagram
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/ald_system_diagram_light_theme.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Component Labels - Distributed around the edges
                    // N₂ Gas Flow - Far Left
                    Positioned(
                      left: 16,
                      top: 100,
                      child: _buildComponentLabel('N₂ Gas Flow', '20 sccm'),
                    ),

                    // Reaction Chamber - Top Center
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.25,
                      top: 16,
                      child:
                          _buildComponentLabel('Reaction Chamber', '150.2°C'),
                    ),

                    // Chamber Pressure - Top Right
                    Positioned(
                      right: 16,
                      top: 16,
                      child: _buildComponentLabel(
                          'Chamber Pressure', '1.2e-6 Torr'),
                    ),

                    // Precursor Flow - Right Middle
                    Positioned(
                      right: 16,
                      top: 120,
                      child: _buildComponentLabel('Precursor Flow', '5 sccm'),
                    ),

                    // Vacuum System - Bottom Right
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: _buildComponentLabel('Vacuum System', 'Active'),
                    ),
                  ],
                ),
              ),

              // Attribution
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Text(
                      'Real-time system visualization',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComponentLabel(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      constraints: BoxConstraints(maxWidth: 120),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid(ThemeData theme) {
    final items = [
      {'title': 'System Health', 'value': 'Optimal'},
      {'title': 'Last Process', 'value': '2024-03-19'},
      {'title': 'Total Cycles', 'value': '1,234'},
      {'title': 'Next Service', 'value': '15 days'},
    ];

    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: items.map((item) => _buildStatusGridItem(item)).toList(),
      ),
    );
  }

  Widget _buildStatusGridItem(Map<String, String> item) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFF5F5F5).withOpacity(0.9),
              Color(0xFFE8F5E9).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item['title']!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['value']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab {
  final IconData icon;
  final String label;

  _DashboardTab(this.icon, this.label);
}

enum OverlayType {
  componentControl,
  parameterMonitor,
  flowVisualization,
}

enum MachineStatus {
  idle,
  processing,
  error,
  maintenance,
}
