import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditSheet extends StatefulWidget {
  final String name;
  final String email;
  final String? profileImageUrl;
  final List<Map<String, dynamic>> education;
  final List<Map<String, dynamic>> experience;
  final List<String> skills;

  final Future<void> Function(
    Map<String, dynamic> data,
    XFile? image,
  )? onSave;

  const ProfileEditSheet({
    super.key,
    required this.name,
    required this.email,
    required this.education,
    required this.experience,
    required this.skills,
    this.profileImageUrl,
    this.onSave,
  });

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _skills;

  final List<Map<String, TextEditingController>> _education = [];
  final List<Map<String, TextEditingController>> _experience = [];

  XFile? _selectedImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.name);
    _email = TextEditingController(text: widget.email);
    _skills = TextEditingController(
      text: widget.skills.join(', '),
    );

    for (final item in widget.education) {
      _addEducation(item);
    }

    for (final item in widget.experience) {
      _addExperience(item);
    }
  }

  TextEditingController _controller(dynamic value) {
    return TextEditingController(
      text: value?.toString() ?? '',
    );
  }

  void _addEducation([Map<String, dynamic>? item]) {
    setState(() {
      _education.add({
        'degree': _controller(item?['degree']),
        'institution': _controller(item?['institution']),
        'fieldOfStudy': _controller(item?['fieldOfStudy']),
        'startYear': _controller(item?['startYear']),
        'endYear': _controller(item?['endYear']),
      });
    });
  }

  void _addExperience([Map<String, dynamic>? item]) {
    setState(() {
      _experience.add({
        'company': _controller(item?['company']),
        'role': _controller(item?['role']),
        'startDate': _controller(item?['startDate']),
        'endDate': _controller(item?['endDate']),
        'description': _controller(item?['description']),
      });
    });
  }

  void _removeEntry(
    List<Map<String, TextEditingController>> list,
    int index,
  ) {
    setState(() {
      final removed = list.removeAt(index);
      for (final controller in removed.values) {
        controller.dispose();
      }
    });
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  int? _number(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value.trim());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final educationData = <Map<String, dynamic>>[];

    for (final item in _education) {
      if (item.values.every((c) => c.text.trim().isEmpty)) {
        continue;
      }

      educationData.add({
        'degree': item['degree']!.text.trim(),
        'institution': item['institution']!.text.trim(),
        'fieldOfStudy': item['fieldOfStudy']!.text.trim(),
        'startYear': _number(item['startYear']!.text),
        'endYear': _number(item['endYear']!.text),
      });
    }

    final experienceData = <Map<String, dynamic>>[];

    for (final item in _experience) {
      if (item.values.every((c) => c.text.trim().isEmpty)) {
        continue;
      }

      experienceData.add({
        'company': item['company']!.text.trim(),
        'role': item['role']!.text.trim(),
        'startDate': _number(item['startDate']!.text),
        'endDate': _number(item['endDate']!.text),
        'description': item['description']!.text.trim(),
      });
    }

    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'email': _email.text.trim(),
      'education': educationData,
      'experience': experienceData,
      'skills': _skills.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList(),
    };

    if (widget.onSave == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connect your profile update API to save.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await widget.onSave!(data, _selectedImage);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _skills.dispose();

    for (final item in [..._education, ..._experience]) {
      for (final controller in item.values) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF171326).withOpacity(0.97),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 28,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Edit Profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Profile picture
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.deepPurpleAccent,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: _selectedImage != null
                                    ? Image.file(
                                        File(_selectedImage!.path),
                                        fit: BoxFit.cover,
                                      )
                                    : (widget.profileImageUrl != null &&
                                            widget.profileImageUrl!.isNotEmpty)
                                        ? (widget.profileImageUrl!
                                                .startsWith('data:')
                                            ? Image.memory(
                                                base64Decode(widget
                                                    .profileImageUrl!
                                                    .split(',')[1]),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _fallbackAvatar(),
                                              )
                                            : Image.network(
                                                widget.profileImageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _fallbackAvatar(),
                                              ))
                                        : _fallbackAvatar(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurpleAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Tap to change profile picture',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _heading('Personal Information'),

                    const SizedBox(height: 12),

                    _field('Full Name', _name),
                    _field(
                      'Email Address',
                      _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    _heading('Education'),

                    const SizedBox(height: 12),

                    ..._education.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return _entryCard(
                        title: 'Education ${index + 1}',
                        onRemove: () => _removeEntry(_education, index),
                        children: [
                          _field('Degree', item['degree']!),
                          _field(
                            'Institution',
                            item['institution']!,
                          ),
                          _field(
                            'Field of Study',
                            item['fieldOfStudy']!,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  'Start Year',
                                  item['startYear']!,
                                  keyboardType: TextInputType.number,
                                  numericOnly: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _field(
                                  'End Year',
                                  item['endYear']!,
                                  keyboardType: TextInputType.number,
                                  numericOnly: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),

                    _addButton(
                      'Add Education',
                      () => _addEducation(),
                    ),

                    const SizedBox(height: 22),

                    _heading('Experience'),

                    const SizedBox(height: 12),

                    ..._experience.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return _entryCard(
                        title: 'Experience ${index + 1}',
                        onRemove: () => _removeEntry(_experience, index),
                        children: [
                          _field('Company', item['company']!),
                          _field('Job Role', item['role']!),
                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  'Start Year',
                                  item['startDate']!,
                                  keyboardType: TextInputType.number,
                                  numericOnly: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _field(
                                  'End Year',
                                  item['endDate']!,
                                  keyboardType: TextInputType.number,
                                  numericOnly: true,
                                ),
                              ),
                            ],
                          ),
                          _field(
                            'Description',
                            item['description']!,
                            maxLines: 3,
                          ),
                        ],
                      );
                    }),

                    _addButton(
                      'Add Experience',
                      () => _addExperience(),
                    ),

                    const SizedBox(height: 22),

                    _heading('Skills'),

                    const SizedBox(height: 8),

                    _field(
                      'Skills separated by commas',
                      _skills,
                      maxLines: 3,
                      hint: 'Flutter, Dart, Node.js, MongoDB',
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      color: Colors.deepPurple.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _heading(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool numericOnly = false,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator ??
            (numericOnly
                ? (value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        int.tryParse(value.trim()) == null) {
                      return 'Enter a valid year';
                    }
                    return null;
                  }
                : null),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white60),
          hintStyle: const TextStyle(color: Colors.white30),
          filled: true,
          fillColor: Colors.white.withOpacity(0.04),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.deepPurpleAccent,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  Widget _entryCard({
    required String title,
    required VoidCallback onRemove,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
                tooltip: 'Remove entry',
              ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.deepPurpleAccent,
        side: BorderSide(
          color: Colors.deepPurpleAccent.withOpacity(0.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
