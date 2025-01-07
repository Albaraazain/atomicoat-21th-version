import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class DarkThemeColors {
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primaryText = Color(0xFFE0E0E0);
  static const Color secondaryText = Color(0xFFB0B0B0);
  static const Color accent = Color(0xFF64FFDA);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color inputFill = Color(0xFF2C2C2C);
}

class RecipeCreationScreen extends StatefulWidget {
  final String? recipeId;
  final String machineId;

  const RecipeCreationScreen(
      {super.key, this.recipeId, required this.machineId});

  @override
  _RecipeCreationScreenState createState() => _RecipeCreationScreenState();
}

class _RecipeCreationScreenState extends State<RecipeCreationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _substrateController;
  late TextEditingController _chamberTempController;
  late TextEditingController _pressureController;
  List<RecipeStep> _steps = [];
  bool _isPublic = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentStep = 0;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _substrateController = TextEditingController();
    _chamberTempController = TextEditingController(text: '150.0');
    _pressureController = TextEditingController(text: '1.0');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    if (widget.recipeId != null) {
      _loadRecipeData();
    }
  }

  void _loadRecipeData() async {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final recipe = await recipeProvider.getRecipeById(widget.recipeId!);
    if (recipe != null) {
      setState(() {
        _nameController.text = recipe.name;
        _descriptionController.text = recipe.description;
        _substrateController.text = recipe.substrate ?? '';
        _chamberTempController.text =
            recipe.chamberTemperatureSetPoint.toString();
        _pressureController.text = recipe.pressureSetPoint.toString();
        _steps = List.from(recipe.steps);
        _isPublic = recipe.isPublic;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _substrateController.dispose();
    _chamberTempController.dispose();
    _pressureController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkThemeColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DarkThemeColors.background,
        title: Text(
          widget.recipeId == null ? 'Create Recipe' : 'Edit Recipe',
          style: TextStyle(color: DarkThemeColors.primaryText),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveRecipe,
            color: DarkThemeColors.accent,
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          bool isLastStep = _currentStep == 2;
          if (isLastStep) {
            _saveRecipe();
          } else {
            setState(() {
              _currentStep += 1;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        onStepTapped: (step) {
          setState(() {
            _currentStep = step;
          });
        },
        steps: [
          Step(
            title: Text('Basic Information',
              style: TextStyle(color: DarkThemeColors.primaryText)),
            content: Form(
              key: _formKeys[0],
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: DarkThemeColors.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Recipe Name *',
                      helperText: 'Enter a descriptive name for your recipe',
                      filled: true,
                      fillColor: DarkThemeColors.inputFill,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a recipe name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(color: DarkThemeColors.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Description *',
                      helperText: 'Describe what this recipe does',
                      filled: true,
                      fillColor: DarkThemeColors.inputFill,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: Text('Parameters',
              style: TextStyle(color: DarkThemeColors.primaryText)),
            content: Form(
              key: _formKeys[1],
              child: Column(
                children: [
                  TextFormField(
                    controller: _substrateController,
                    style: TextStyle(color: DarkThemeColors.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Substrate',
                      helperText: 'The material being processed (optional)',
                      filled: true,
                      fillColor: DarkThemeColors.inputFill,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _chamberTempController,
                    style: TextStyle(color: DarkThemeColors.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Chamber Temperature (°C) *',
                      helperText: 'Target temperature for the process',
                      filled: true,
                      fillColor: DarkThemeColors.inputFill,
                      suffixText: '°C',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter chamber temperature';
                      }
                      final temp = double.tryParse(value);
                      if (temp == null) {
                        return 'Please enter a valid number';
                      }
                      if (temp < 0 || temp > 1000) {
                        return 'Temperature must be between 0°C and 1000°C';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pressureController,
                    style: TextStyle(color: DarkThemeColors.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Pressure (Torr) *',
                      helperText: 'Target pressure for the process',
                      filled: true,
                      fillColor: DarkThemeColors.inputFill,
                      suffixText: 'Torr',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pressure';
                      }
                      final pressure = double.tryParse(value);
                      if (pressure == null) {
                        return 'Please enter a valid number';
                      }
                      if (pressure < 0 || pressure > 760) {
                        return 'Pressure must be between 0 and 760 Torr';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      'Make Recipe Public',
                      style: TextStyle(color: DarkThemeColors.primaryText),
                    ),
                    subtitle: Text(
                      'Allow other users to view and use this recipe',
                      style: TextStyle(color: DarkThemeColors.secondaryText),
                    ),
                    value: _isPublic,
                    onChanged: (bool value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                    activeColor: DarkThemeColors.accent,
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: Text('Recipe Steps',
              style: TextStyle(color: DarkThemeColors.primaryText)),
            content: Form(
              key: _formKeys[2],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add the steps for your recipe in sequence',
                    style: TextStyle(
                      color: DarkThemeColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildStepsList(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addStep,
                    icon: Icon(Icons.add),
                    label: Text('Add Step'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DarkThemeColors.accent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                    ),
                  ),
                  if (_steps.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Add at least one step to your recipe',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStepsList() {
    return _steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      return Card(
        margin: const EdgeInsets.only(bottom: 8.0),
        color: DarkThemeColors.cardBackground,
        child: ListTile(
          title: Text(
            step.name,
            style: TextStyle(color: DarkThemeColors.primaryText),
          ),
          subtitle: Text(
            step.description,
            style: TextStyle(color: DarkThemeColors.secondaryText),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                color: DarkThemeColors.accent,
                onPressed: () => _editStep(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () => _deleteStep(index),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _addStep() {
    showDialog(
      context: context,
      builder: (context) => StepDialog(
        onSave: (step) {
          setState(() {
            _steps.add(step);
          });
        },
        nextSequenceNumber: _steps.length + 1,
      ),
    );
  }

  void _editStep(int index) {
    showDialog(
      context: context,
      builder: (context) => StepDialog(
        initialStep: _steps[index],
        onSave: (step) {
          setState(() {
            _steps[index] = step;
          });
        },
        nextSequenceNumber: _steps[index].sequenceNumber,
      ),
    );
  }

  void _deleteStep(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DarkThemeColors.cardBackground,
        title: Text(
          'Delete Step',
          style: TextStyle(color: DarkThemeColors.primaryText),
        ),
        content: Text(
          'Are you sure you want to delete this step?',
          style: TextStyle(color: DarkThemeColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: DarkThemeColors.accent),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _steps.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecipe() async {
    // Validate current step
    if (!_formKeys[_currentStep].currentState!.validate()) {
      return;
    }

    // Validate all steps if on the final step
    if (_currentStep == 2) {
      bool isValid = true;
      for (var key in _formKeys) {
        if (!key.currentState!.validate()) {
          isValid = false;
        }
      }
      if (!isValid) {
        _showError('Please check all fields and try again');
        return;
      }

      if (_steps.isEmpty) {
        _showError('Recipe must have at least one step');
        return;
      }
    }

    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    if (recipeProvider.currentUserId == null) {
      _showError('You must be logged in to create a recipe');
      return;
    }

    if (recipeProvider.currentMachineType == null) {
      _showError('Please select a machine type first');
      return;
    }

    final now = DateTime.now();
    final recipe = Recipe(
      id: widget.recipeId ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      steps: _steps,
      isPublic: _isPublic,
      version: 1,
      createdBy: recipeProvider.currentUserId!,
      machineType: recipeProvider.currentMachineType!,
      substrate: _substrateController.text.trim().isEmpty
        ? null
        : _substrateController.text.trim(),
      chamberTemperatureSetPoint: double.tryParse(_chamberTempController.text) ?? 150.0,
      pressureSetPoint: double.tryParse(_pressureController.text) ?? 1.0,
      createdAt: now,
      updatedAt: now,
    );

    try {
      if (widget.recipeId == null) {
        await recipeProvider.createRecipe(recipe);
        _showSuccess('Recipe created successfully');
      } else {
        await recipeProvider.updateRecipe(recipe);
        _showSuccess('Recipe updated successfully');
      }

      Navigator.of(context).pop();
    } catch (e) {
      if (e.toString().contains('begin_transaction')) {
        _showError('Unable to create recipe. Please try again later.');
      } else {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class StepDialog extends StatefulWidget {
  final RecipeStep? initialStep;
  final Function(RecipeStep) onSave;
  final int nextSequenceNumber;

  const StepDialog({
    super.key,
    this.initialStep,
    required this.onSave,
    required this.nextSequenceNumber,
  });

  @override
  _StepDialogState createState() => _StepDialogState();
}

class _StepDialogState extends State<StepDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late StepType _selectedType;
  late Map<String, dynamic> _parameters;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialStep?.name ?? 'New Step',
    );
    _descriptionController = TextEditingController(
      text: widget.initialStep?.description ?? 'Step description',
    );
    _selectedType = widget.initialStep?.type ?? StepType.valve;
    _parameters = widget.initialStep != null
        ? Map<String, dynamic>.from(widget.initialStep!.parameters)
        : _getDefaultParameters(_selectedType);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    final step = RecipeStep(
      id: widget.initialStep?.id,
      name: _nameController.text,
      description: _descriptionController.text,
      type: _selectedType,
      parameters: Map<String, dynamic>.from(_parameters),
      sequenceNumber: widget.nextSequenceNumber,
    );
    widget.onSave(step);
    Navigator.of(context).pop();
  }

  Map<String, dynamic> _getDefaultParameters(StepType type) {
    switch (type) {
      case StepType.valve:
        return {
          'valveType': 'valveA',
          'duration': 5.0,
          'temperature': 200.0,
          'pressure': 1.0,
        };
      case StepType.purge:
        return {
          'duration': 10.0,
          'flowRate': 100.0,
        };
      case StepType.loop:
        return {
          'iterations': 1,
        };
      case StepType.setParameter:
        return {
          'component': '',
          'parameter': '',
          'value': 0.0,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DarkThemeColors.cardBackground,
      title: Text(
        widget.initialStep == null ? 'Add Step' : 'Edit Step',
        style: TextStyle(color: DarkThemeColors.primaryText),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: DarkThemeColors.primaryText),
              decoration: InputDecoration(
                labelText: 'Step Name',
                filled: true,
                fillColor: DarkThemeColors.inputFill,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(color: DarkThemeColors.primaryText),
              decoration: InputDecoration(
                labelText: 'Description',
                filled: true,
                fillColor: DarkThemeColors.inputFill,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<StepType>(
              value: _selectedType,
              style: TextStyle(color: DarkThemeColors.primaryText),
              dropdownColor: DarkThemeColors.cardBackground,
              decoration: InputDecoration(
                labelText: 'Step Type',
                filled: true,
                fillColor: DarkThemeColors.inputFill,
              ),
              items: StepType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    _parameters = _getDefaultParameters(value);
                  });
                }
              },
            ),
            SizedBox(height: 16),
            _buildParameterFields(),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: DarkThemeColors.accent),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _save,
          child: Text(
            'Save',
            style: TextStyle(color: DarkThemeColors.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildParameterFields() {
    switch (_selectedType) {
      case StepType.valve:
        return Column(
          children: [
            DropdownButtonFormField<String>(
              value: _parameters['valveType'] as String,
              style: TextStyle(color: DarkThemeColors.primaryText),
              dropdownColor: DarkThemeColors.cardBackground,
              decoration: InputDecoration(
                labelText: 'Valve Type',
                filled: true,
                fillColor: DarkThemeColors.inputFill,
              ),
              items: ['valveA', 'valveB'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _parameters['valveType'] = value;
                  });
                }
              },
            ),
            _buildNumberField('Duration (s)', 'duration'),
            _buildNumberField('Temperature (°C)', 'temperature'),
            _buildNumberField('Pressure (Torr)', 'pressure'),
          ],
        );
      case StepType.purge:
        return Column(
          children: [
            _buildNumberField('Duration (s)', 'duration'),
            _buildNumberField('Flow Rate (sccm)', 'flowRate'),
          ],
        );
      case StepType.loop:
        return _buildNumberField('Number of Iterations', 'iterations');
      case StepType.setParameter:
        return Column(
          children: [
            TextFormField(
              initialValue: _parameters['component'] as String,
              style: TextStyle(color: DarkThemeColors.primaryText),
              decoration: InputDecoration(
                labelText: 'Component Name',
                filled: true,
                fillColor: DarkThemeColors.inputFill,
              ),
              onChanged: (value) {
                _parameters['component'] = value;
              },
            ),
            TextFormField(
              initialValue: _parameters['parameter'] as String,
              style: TextStyle(color: DarkThemeColors.primaryText),
              decoration: InputDecoration(
                labelText: 'Parameter Name',
                filled: true,
                fillColor: DarkThemeColors.inputFill,
              ),
              onChanged: (value) {
                _parameters['parameter'] = value;
              },
            ),
            _buildNumberField('Value', 'value'),
          ],
        );
    }
  }

  Widget _buildNumberField(String label, String key) {
    return TextFormField(
      initialValue: _parameters[key].toString(),
      style: TextStyle(color: DarkThemeColors.primaryText),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: DarkThemeColors.inputFill,
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _parameters[key] = double.tryParse(value) ?? 0.0;
      },
    );
  }
}
