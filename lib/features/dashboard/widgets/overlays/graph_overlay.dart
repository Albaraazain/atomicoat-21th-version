import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/components/providers/component_provider.dart';
import '../../../../features/components/models/component.dart';
import '../../../../features/components/models/component_parameter.dart';

class GraphOverlay extends StatefulWidget {
  final String overlayId;

  const GraphOverlay({super.key, required this.overlayId});

  @override
  _GraphOverlayState createState() => _GraphOverlayState();
}

class _GraphOverlayState extends State<GraphOverlay> {
  Map<String, Offset> _componentPositions = {};
  Size _diagramSize = Size.zero;
  bool _isEditMode = false;
  bool _isInitialized = false;
  final GlobalKey _diagramKey = GlobalKey();

  // Define relative positions from center (x, y as percentages from -1.0 to 1.0)
  final Map<String, Offset> _defaultRelativePositions = {
    'Nitrogen Generator': Offset(-0.85, 0.33),
    'MFC': Offset(-0.60, -0.49),
    'Backline Heater': Offset(-0.37, -0.43),
    'Precursor 1': Offset(-0.55, 0.75),
    'Precursor 2': Offset(-0.19, 0.75),
    'Reaction Chamber': Offset(0.04, -0.52),
    'Frontend Heater': Offset(0.38, -0.41),
    'Pressure Control': Offset(0.60, -0.47),
  };

  final Map<String, Color> componentColors = {
    'Nitrogen Generator': Colors.blue[700]!,
    'MFC': Colors.green[600]!,
    'Backline Heater': Colors.orange[600]!,
    'Precursor 1': Colors.teal[600]!,
    'Precursor 2': Colors.indigo[600]!,
    'Reaction Chamber': Colors.red[600]!,
    'Frontend Heater': Colors.amber[700]!,
    'Pressure Control': Colors.cyan[700]!,
  };

  @override
  void initState() {
    super.initState();
    _loadComponentPositions();
    // Reset positions to defaults to make all components visible initially
    _resetComponentPositions();
  }

  void _updateDiagramSize(Size size) {
    if (_diagramSize != size) {
      _diagramSize = size;
      if (!_isInitialized) {
        _initializeDefaultPositions();
        _isInitialized = true;
      }
    }
  }

  // Convert relative position (-1 to 1) to actual position
  Offset _relativeToAbsolute(Offset relativePos) {
    final centerX = _diagramSize.width / 2;
    final centerY = _diagramSize.height / 2;
    return Offset(
      centerX + (relativePos.dx * centerX),
      centerY + (relativePos.dy * centerY),
    );
  }

  // Convert actual position to relative position (-1 to 1)
  Offset _absoluteToRelative(Offset absolutePos) {
    final centerX = _diagramSize.width / 2;
    final centerY = _diagramSize.height / 2;
    return Offset(
      (absolutePos.dx - centerX) / centerX,
      (absolutePos.dy - centerY) / centerY,
    );
  }

  void _initializeDefaultPositions() {
    final random = Random();
    _componentPositions = Map.fromEntries(
      _defaultRelativePositions.entries.map((entry) {
        final basePosition = _relativeToAbsolute(entry.value);
        // Add a small random offset to prevent complete overlap
        if (entry.key != 'Reaction Chamber') {
          return MapEntry(
            entry.key,
            Offset(
              basePosition.dx + (random.nextDouble() - 0.5) * 20,
              basePosition.dy + (random.nextDouble() - 0.5) * 20,
            ),
          );
        }
        return MapEntry(entry.key, basePosition);
      }),
    );
  }

  void _logCurrentPositions() {
    final relativePositions = _componentPositions.map((key, value) {
      final relativePos = _absoluteToRelative(value);
      return MapEntry(key, relativePos);
    });

    // Format positions as Dart code
    final StringBuffer code = StringBuffer();
    code.writeln('final Map<String, Offset> _defaultRelativePositions = {');
    relativePositions.forEach((key, value) {
      code.writeln(
          "  '$key': Offset(${value.dx.toStringAsFixed(2)}, ${value.dy.toStringAsFixed(2)}),");
    });
    code.writeln('};');

    // Print to console and save to clipboard
    print('\nCurrent Relative Positions:');
    print(code.toString());

    // TODO: You might want to add a proper logging mechanism or save to a file
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _updateDiagramSize(Size(constraints.maxWidth, constraints.maxHeight));

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Background ALD system diagram
            Positioned.fill(
              child: Image.asset(
                'assets/ald_system_diagram_light_theme.png',
                fit: BoxFit.contain,
              ),
            ),

            // Component graphs overlaid on the diagram
            ...componentColors.entries.map((entry) {
              final componentName = entry.key;
              final position = _componentPositions[componentName];
              if (position == null) return const SizedBox.shrink();

              return Positioned(
                left: position.dx - 90,
                top: position.dy - 70,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onPanUpdate: _isEditMode
                        ? (details) {
                            setState(() {
                              _componentPositions[componentName] = Offset(
                                _componentPositions[componentName]!.dx +
                                    details.delta.dx,
                                _componentPositions[componentName]!.dy +
                                    details.delta.dy,
                              );
                            });
                          }
                        : null,
                    onPanEnd: _isEditMode
                        ? (_) {
                            _saveComponentPositions();
                          }
                        : null,
                    child: _buildComponentGraph(
                      componentName,
                      entry.value,
                      false,
                    ),
                  ),
                ),
              );
            }).toList(),

            // Controls overlay
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isEditMode) ...[
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.restart_alt, color: Colors.orange),
                          onPressed: _resetComponentPositions,
                          tooltip: 'Reset Positions',
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.save_alt, color: Colors.blue),
                          onPressed: _logCurrentPositions,
                          tooltip: 'Log Current Positions',
                        ),
                      ),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isEditMode ? Icons.lock_open : Icons.lock,
                          color: _isEditMode ? Colors.green : Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditMode = !_isEditMode;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Debug overlay for component positions
            if (_isEditMode) ...[
              ...componentColors.entries.map((entry) {
                final componentName = entry.key;
                final position = _componentPositions[componentName];
                if (position == null) return const SizedBox.shrink();
                return Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Container(
                    width: 4,
                    height: 4,
                    color: Colors.red,
                  ),
                );
              }).toList(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildComponentGraph(String name, Color color, bool isVacuumPump) {
    // Mock set value - in real app this would come from your component data
    final double setValue = 2.5;

    return Container(
      width: 180, // Increased width
      height: 140, // Increased height
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Set: ${setValue.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: Stack(
              children: [
                // Set value line container with label
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: color.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                    margin: EdgeInsets.only(
                        top: 45), // Position in middle of graph area
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 11,
                      minY: setValue - 1.5,
                      maxY: setValue + 1.5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(12, (index) {
                            final variation = sin(index * 0.5) * 1.2;
                            return FlSpot(
                              index.toDouble(),
                              setValue + variation,
                            );
                          }),
                          isCurved: true,
                          color: color,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: color.withOpacity(0.1),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(enabled: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('component_positions_graph_overlay_${widget.overlayId}');
    _initializeDefaultPositions();
    setState(() {});
  }

  Future<void> _loadComponentPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionsJson = prefs
          .getString('component_positions_graph_overlay_${widget.overlayId}');

      if (positionsJson != null) {
        final positionsMap = jsonDecode(positionsJson) as Map<String, dynamic>;
        setState(() {
          _componentPositions = positionsMap.map((key, value) {
            final offsetList = (value as List<dynamic>).cast<double>();
            return MapEntry(key, Offset(offsetList[0], offsetList[1]));
          });
        });
      } else {
        _initializeDefaultPositions();
      }
    } catch (e) {
      print("Error loading component positions: $e");
      _initializeDefaultPositions();
    }
  }

  Future<void> _saveComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final positionsMap = _componentPositions.map((key, value) {
      return MapEntry(key, [value.dx, value.dy]);
    });
    await prefs.setString(
        'component_positions_graph_overlay_${widget.overlayId}',
        jsonEncode(positionsMap));
  }
}
