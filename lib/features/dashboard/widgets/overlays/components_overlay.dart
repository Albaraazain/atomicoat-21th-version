import 'package:flutter/material.dart';

class ComponentsOverlay extends StatefulWidget {
  const ComponentsOverlay({super.key});

  @override
  _ComponentsOverlayState createState() => _ComponentsOverlayState();
}

class _ComponentsOverlayState extends State<ComponentsOverlay> {
  // Hardcoded component data for now
  final List<ComponentData> components = [
    ComponentData(
      name: 'Nitrogen Generator',
      position: Offset(0.1, 0.2),
      parameters: {
        'Flow Rate': '10 L/min',
        'Pressure': '2.5 bar',
        'Temperature': '25°C',
      },
    ),
    ComponentData(
      name: 'MFC',
      position: Offset(0.3, 0.4),
      parameters: {
        'Flow Rate': '5 L/min',
        'Setpoint': '5.5 L/min',
        'Valve Position': '80%',
      },
    ),
    ComponentData(
      name: 'Reaction Chamber',
      position: Offset(0.5, 0.5),
      parameters: {
        'Temperature': '250°C',
        'Pressure': '1.2 Torr',
        'Vacuum Level': '10^-3 Torr',
      },
    ),
    // Add more components as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Stack(
        children: [
          // Background ALD system diagram
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/ald_system_diagram_light_theme.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Component labels with modern styling
          ...components.map((component) {
            return Positioned(
              left: component.position.dx * MediaQuery.of(context).size.width,
              top: component.position.dy * MediaQuery.of(context).size.height,
              child: _buildComponentCard(component),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComponentCard(ComponentData component) {
    return GestureDetector(
      onTap: () {
        // Show component details modal
        _showComponentDetails(component);
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 160),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              component.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            ...component.parameters.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showComponentDetails(ComponentData component) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      component.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Parameters', component.parameters),
                      SizedBox(height: 24),
                      _buildDetailSection('Controls', {
                        'Power': 'ON',
                        'Mode': 'Automatic',
                        'Status': 'Operating',
                      }),
                      SizedBox(height: 24),
                      _buildDetailSection('Maintenance', {
                        'Last Service': '2024-02-15',
                        'Next Service': '2024-05-15',
                        'Operating Hours': '1,234',
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, Map<String, String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        SizedBox(height: 16),
        ...details.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  '${entry.key}:',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  entry.value,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class ComponentData {
  final String name;
  final Offset position;
  final Map<String, String> parameters;

  ComponentData({
    required this.name,
    required this.position,
    required this.parameters,
  });
}
