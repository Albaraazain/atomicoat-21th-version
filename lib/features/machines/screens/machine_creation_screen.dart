import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/machine_provider.dart';

class MachineCreationScreen extends StatefulWidget {
  const MachineCreationScreen({super.key});

  @override
  _MachineCreationScreenState createState() => _MachineCreationScreenState();
}

class _MachineCreationScreenState extends State<MachineCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labNameController = TextEditingController();
  final _labInstitutionController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _adminEmailController = TextEditingController();

  String _selectedMachineType = 'Thermal ALD';
  String _selectedModel = 'ALD-2000';
  bool _isLoading = false;

  @override
  void dispose() {
    _labNameController.dispose();
    _labInstitutionController.dispose();
    _serialNumberController.dispose();
    _locationController.dispose();
    _adminEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('Add New Machine'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              SizedBox(height: 16),
              _buildTextField(
                controller: _serialNumberController,
                label: 'Serial Number',
                hint: 'Enter serial number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter serial number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Machine Specifications'),
              SizedBox(height: 16),
              _buildDropdown(
                label: 'Machine Type',
                value: _selectedMachineType,
                items: ['Thermal ALD', 'Plasma ALD', 'Spatial ALD'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMachineType = value);
                  }
                },
              ),
              SizedBox(height: 16),
              _buildDropdown(
                label: 'Model',
                value: _selectedModel,
                items: ['ALD-2000', 'ALD-3000', 'ALD-4000'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedModel = value);
                  }
                },
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Lab Information'),
              SizedBox(height: 16),
              _buildTextField(
                controller: _labNameController,
                label: 'Lab Name',
                hint: 'Enter lab name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter lab name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _labInstitutionController,
                label: 'Lab Institution',
                hint: 'Enter institution name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter institution name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Enter machine location',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _buildSectionTitle('Admin Information'),
              SizedBox(height: 16),
              _buildTextField(
                controller: _adminEmailController,
                label: 'Admin Email',
                hint: 'Enter admin email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter admin email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Color(0xFF2A2A2A),
              style: TextStyle(color: Colors.white),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Create Machine',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final machineProvider = context.read<MachineProvider>();

        final response = await machineProvider.createMachine(
          serialNumber: _serialNumberController.text,
          location: _locationController.text,
          labName: _labNameController.text,
          labInstitution: _labInstitutionController.text,
          model: _selectedModel,
          machineType: _selectedMachineType,
          adminEmail: _adminEmailController.text,
        );

        if (response != null) {
          if (!mounted) return;

          // Show success message with admin credentials if new admin was created
          if (response['admin_password'] != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Machine created successfully. Admin credentials:\nEmail: ${response['admin_email']}\nPassword: ${response['admin_password']}'
                ),
                duration: Duration(seconds: 10),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Machine created successfully')),
            );
          }
          Navigator.pop(context);
        } else {
          throw Exception('Failed to create machine');
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
