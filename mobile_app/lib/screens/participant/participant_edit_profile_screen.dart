import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class EditPersonalInfoScreen extends StatelessWidget {
  final Map<String, dynamic> initialData;

  const EditPersonalInfoScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) {
    return _EditProfileForm(
      title: 'Edit Personal Info',
      initialData: initialData,
      fields: const [
        _EditField('age', 'Age', TextInputType.number),
        _EditField('profession', 'Profession', TextInputType.text),
        _EditField('phone', 'Phone', TextInputType.phone),
      ],
    );
  }
}

class EditBiometricsScreen extends StatelessWidget {
  final Map<String, dynamic> initialData;

  const EditBiometricsScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) {
    return _EditProfileForm(
      title: 'Edit Biometrics',
      initialData: initialData,
      fields: const [
        _EditField('height_cm', 'Height cm', TextInputType.number),
        _EditField('weight_kg', 'Weight kg', TextInputType.number),
        _EditField('neck_cm', 'Neck cm', TextInputType.number),
        _EditField('waist_cm', 'Waist cm', TextInputType.number),
        _EditField('bmi', 'BMI', TextInputType.number),
      ],
    );
  }
}

class EditLifestyleScreen extends StatelessWidget {
  final Map<String, dynamic> initialData;

  const EditLifestyleScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) {
    return _EditProfileForm(
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
}

class EditGoalsScreen extends StatelessWidget {
  final Map<String, dynamic> initialData;

  const EditGoalsScreen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context) {
    return _EditProfileForm(
      title: 'Edit Goals',
      initialData: initialData,
      fields: const [
        _EditField('goals', 'Goals', TextInputType.multiline),
      ],
    );
  }
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

  const _EditProfileForm({
    required this.title,
    required this.initialData,
    required this.fields,
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
        text: clean(widget.initialData[field.keyName]),
      );
    }
  }

  String clean(dynamic value) {
    if (value == null) return '';
    final text = value.toString();
    if (text == 'null' || text == 'Not provided') return '';
    return text;
  }

  Future<void> save() async {
    setState(() => isSaving = true);

    final payload = Map<String, dynamic>.from(widget.initialData);

    for (final field in widget.fields) {
      payload[field.keyName] = controllers[field.keyName]!.text.trim();
    }

    final response = await ApiService.post(
      '/profile/save_onboarding.php',
      payload,
      auth: true,
    );

    if (!mounted) return;

    setState(() => isSaving = false);

    if (response['success'] == true) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['message']?.toString() ?? 'Could not save'),
      ),
    );
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
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.18),
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
                  ],
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  child: Column(
                    children: [
                      ...widget.fields.map((field) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextField(
                            controller: controllers[field.keyName],
                            keyboardType: field.keyboardType,
                            maxLines: field.keyboardType == TextInputType.multiline ? 4 : 1,
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
                        );
                      }),
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
                    ],
                  ),
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
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F3D84),
            Color(0xFF2F61D2),
            Color(0xFF5A5CF6),
          ],
        ),
      ),
      child: child,
    );
  }
}