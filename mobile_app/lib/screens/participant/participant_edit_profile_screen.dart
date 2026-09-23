import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class EditPersonalInfoScreen extends StatelessWidget {
  final Map<String, dynamic> initialData;
  const EditPersonalInfoScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) => _EditProfileForm(
        title: 'Edit Personal Info',
        initialData: initialData,
        fields: const [
          _EditField('age', 'Age', TextInputType.number),
          _EditField('profession', 'Profession', TextInputType.text),
          _EditField('phone', 'Phone', TextInputType.phone),
        ],
      );
}

class EditBiometricsScreen extends StatelessWidget {
  final Map<String, dynamic> initialData;
  const EditBiometricsScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) => _EditProfileForm(
        title: 'Edit Biometrics',
        initialData: initialData,
        fields: const [
          _EditField('height_cm', 'Height cm', TextInputType.numberWithOptions(decimal: true)),
          _EditField('weight_kg', 'Weight kg', TextInputType.numberWithOptions(decimal: true)),
          _EditField('neck_cm', 'Neck cm', TextInputType.numberWithOptions(decimal: true)),
          _EditField('waist_cm', 'Waist cm', TextInputType.numberWithOptions(decimal: true)),
        ],
        showCalculatedBmi: true,
      );
}

class EditLifestyleScreen extends StatelessWidget {
  final Map<String, dynamic> initialData;
  const EditLifestyleScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) => _EditProfileForm(
        title: 'Edit Lifestyle',
        initialData: initialData,
        fields: const [
          _EditField('nutrition_habits', 'Nutrition Habits', TextInputType.text),
          _EditField('smoking_habits', 'Smoking Habits', TextInputType.text),
          _EditField('physical_activity', 'Physical Activity', TextInputType.text),
          _EditField('sleep_quality', 'Sleep Quality', TextInputType.text),
        ],
      );
}

class EditGoalsScreen extends StatelessWidget {
  final Map<String, dynamic> initialData;
  const EditGoalsScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) => _EditProfileForm(
        title: 'Edit Goals',
        initialData: initialData,
        fields: const [_EditField('goals', 'Goals', TextInputType.multiline)],
      );
}

class _EditField {
  final String keyName;
  final String label;
  final TextInputType keyboardType;
  const _EditField(this.keyName, this.label, this.keyboardType);
}

class _EditProfileForm extends StatefulWidget {
  final String title;
  final Map<String, dynamic> initialData;
  final List<_EditField> fields;
  final bool showCalculatedBmi;

  const _EditProfileForm({
    required this.title,
    required this.initialData,
    required this.fields,
    this.showCalculatedBmi = false,
  });

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final Map<String, TextEditingController> controllers = {};
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      controllers[field.keyName] = TextEditingController(
        text: _clean(widget.initialData[field.keyName]),
      );
    }
  }

  String _clean(dynamic value) {
    if (value == null) return '';
    if (value is List) return value.join(', ');
    final text = value.toString();
    if (text == 'null' || text == 'Not provided') return '';
    return text;
  }

  double? _number(String key) {
    final text = controllers[key]?.text.trim().replaceAll(',', '.');
    if (text == null || text.isEmpty) return null;
    return double.tryParse(text);
  }

  String _bmiText() {
    final height = _number('height_cm');
    final weight = _number('weight_kg');
    if (height == null || weight == null || height <= 0 || weight <= 0) return '—';
    final meters = height <= 3 ? height : height / 100;
    return (weight / (meters * meters)).toStringAsFixed(2);
  }

  dynamic _valueForPayload(_EditField field) {
    final raw = controllers[field.keyName]!.text.trim();
    if (raw.isEmpty) return null;

    if (const {'height_cm', 'weight_kg', 'neck_cm', 'waist_cm', 'age'}
        .contains(field.keyName)) {
      return raw.replaceAll(',', '.');
    }

    if (field.keyName == 'goals') {
      return raw
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return raw;
  }

  Future<void> save() async {
    if (isSaving) return;

    if (widget.showCalculatedBmi) {
      final height = _number('height_cm');
      final weight = _number('weight_kg');
      final neck = _number('neck_cm');
      final waist = _number('waist_cm');

      if (height == null || height <= 0 || weight == null || weight <= 0) {
        _showMessage('Height and weight must be valid numbers greater than 0.');
        return;
      }
      if (neck != null && neck <= 0) {
        _showMessage('Neck must be a valid number greater than 0.');
        return;
      }
      if (waist != null && waist <= 0) {
        _showMessage('Waist must be a valid number greater than 0.');
        return;
      }
    }

    setState(() => isSaving = true);
    try {
      final payload = Map<String, dynamic>.from(widget.initialData);
      for (final field in widget.fields) {
        payload[field.keyName] = _valueForPayload(field);
      }
      // BMI is always calculated by the backend from height + weight.
      payload.remove('bmi');

      final response = await ApiService.post(
        '/profile/save_onboarding.php',
        payload,
        auth: true,
      );

      if (!mounted) return;
      if (response['success'] == true) {
        Navigator.pop(context, true);
      } else {
        _showMessage(response['message']?.toString() ?? 'Could not save');
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Column(children: [
                    ...widget.fields.map((field) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextField(
                            controller: controllers[field.keyName],
                            keyboardType: field.keyboardType,
                            maxLines: field.keyboardType == TextInputType.multiline ? 4 : 1,
                            onChanged: widget.showCalculatedBmi ? (_) => setState(() {}) : null,
                            decoration: InputDecoration(
                              labelText: field.label,
                              filled: true,
                              fillColor: const Color(0xFFF4F6FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        )),
                    if (widget.showCalculatedBmi)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'BMI (calculated automatically)',
                            filled: true,
                            fillColor: const Color(0xFFF4F6FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          child: Text(_bmiText()),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F61D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(isSaving ? 'Saving...' : 'Save Changes'),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Gradient extends StatelessWidget {
  final Widget child;
  const _Gradient({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F3D84), Color(0xFF2F61D2), Color(0xFF5A5CF6)],
          ),
        ),
        child: child,
      );
}
