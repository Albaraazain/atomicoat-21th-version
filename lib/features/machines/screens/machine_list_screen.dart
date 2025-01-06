import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../providers/machine_provider.dart';
import '../models/machine.dart';
import '../../../core/auth/providers/auth_provider.dart';
import '../../../widgets/app_drawer.dart';

class MachineListScreen extends StatefulWidget {
  const MachineListScreen({super.key});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _logger = Logger();
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeMachines();
      _isInitialized = true;
    }
  }

  Future<void> _initializeMachines() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.userId != null) {
      await context.read<MachineProvider>().loadMachinesForAdmin(authProvider.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _logger.i('Opening app drawer from MachineListScreen');
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text('ALD Machines'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/machines/create'),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Consumer<MachineProvider>(
        builder: (context, machineProvider, child) {
          if (machineProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (machineProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading machines',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    machineProvider.error!,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeMachines,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (machineProvider.machines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No machines found',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/machines/create'),
                    child: Text('Add Machine'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _initializeMachines,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: machineProvider.machines.length,
              itemBuilder: (context, index) {
                final machine = machineProvider.machines[index];
                return _buildMachineCard(
                  id: machine.id,
                  name: '${machine.model} - ${machine.serialNumber}',
                  status: machine.status,
                  lastMaintenance: machine.lastMaintenance,
                  location: machine.location,
                  context: context,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMachineCard({
    required String id,
    required String name,
    required MachineStatus status,
    required DateTime lastMaintenance,
    required String location,
    required BuildContext context,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/machines/details', arguments: id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    icon: Icons.history,
                    label: 'Last Maintenance',
                    value:
                        '${lastMaintenance.day}/${lastMaintenance.month}/${lastMaintenance.year}',
                  ),
                  _buildInfoItem(
                    icon: Icons.place,
                    label: 'Location',
                    value: location,
                  ),
                  _buildActionButton(context, id),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MachineStatus status) {
    final colors = {
      MachineStatus.offline: Colors.grey,
      MachineStatus.idle: Colors.blue,
      MachineStatus.running: Colors.green,
      MachineStatus.error: Colors.red,
      MachineStatus.maintenance: Colors.orange,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors[status]?.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors[status] ?? Colors.grey),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          color: colors[status],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String machineId) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.white70),
      color: Color(0xFF2A2A2A),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            Navigator.pushNamed(context, '/machines/edit',
                arguments: machineId);
            break;
          case 'delete':
            _showDeleteConfirmation(context, machineId);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text('Edit', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, String machineId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Delete Machine', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this machine? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement machine deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Machine deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
