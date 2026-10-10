import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Represents the user's already-saved resume.
class InterviewResumeOption {
  final String id;
  final String title;
  final String? subtitle;

  const InterviewResumeOption({
    required this.id,
    required this.title,
    this.subtitle,
  });
}

/// Returned when the user presses Continue.
class InterviewSetupResult {
  final String role;

  /// Set when the user chooses an existing resume.
  final InterviewResumeOption? existingResume;

  /// Set when the user chooses a new PDF.
  final PlatformFile? uploadedResume;

  const InterviewSetupResult({
    required this.role,
    this.existingResume,
    this.uploadedResume,
  });

  /// Convenience getter for the selected resume.
  InterviewResumeOption? get resume {
    if (existingResume != null) return existingResume;
    if (uploadedResume != null) {
      return InterviewResumeOption(
        id: 'uploaded_${uploadedResume!.name}',
        title: uploadedResume!.name,
        subtitle: 'Uploaded resume',
      );
    }
    return null;
  }

  bool get isExistingResumeSelected => existingResume != null;

  bool get isNewResumeSelected => uploadedResume != null;
}

Future<InterviewSetupResult?> showInterviewSetupSheet({
  required BuildContext context,
  List<InterviewResumeOption>? resumes,
  InterviewResumeOption? existingResume,
}) {
  final List<InterviewResumeOption> effectiveResumes = [
    if (resumes != null) ...resumes,
    if (resumes == null && existingResume != null) existingResume,
  ];

  return showModalBottomSheet<InterviewSetupResult>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (context) {
      return InterviewSetupSheet(
        resumes: effectiveResumes,
        existingResume: existingResume ?? effectiveResumes.firstOrNull,
      );
    },
  );
}

class InterviewSetupSheet extends StatefulWidget {
  final List<InterviewResumeOption> resumes;
  final InterviewResumeOption? existingResume;

  const InterviewSetupSheet({
    super.key,
    this.resumes = const [],
    this.existingResume,
  });

  @override
  State<InterviewSetupSheet> createState() =>
      _InterviewSetupSheetState();
}

class _InterviewSetupSheetState extends State<InterviewSetupSheet> {
  final TextEditingController _customRoleController =
  TextEditingController();

  String? _selectedRole;
  bool _useExistingResume = true;
  InterviewResumeOption? _selectedExistingResume;
  PlatformFile? _uploadedResume;
  bool _isPickingFile = false;

  static const Color _accent = Color(0xFF8B7CFF);
  static const Color _background = Color(0xFF171729);
  static const Color _muted = Color(0xFFAAAAC4);

  static const List<String> _roles = [
    'Software Developer',
    'Software Engineer',
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'Flutter Developer',
    'Android Developer',
    'iOS Developer',
    'Mobile App Developer',
    'Web Developer',
    'Software Tester',
    'QA Engineer',
    'HR',
    'UI/UX Designer',
    'Product Designer',
    'Product Manager',
    'Business Analyst',
    'Data Analyst',
    'Data Scientist',
    'AI/ML Engineer',
    'Data Engineer',
    'DevOps Engineer',
    'Cloud Engineer',
    'Cybersecurity Engineer',
    'Network Engineer',
    'Database Administrator',
    'Embedded Systems Engineer',
    'Blockchain Developer',
    'Game Developer',
    'Technical Support Engineer',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.resumes.isNotEmpty) {
      _selectedExistingResume = widget.existingResume ?? widget.resumes.first;
      _useExistingResume = true;
    } else if (widget.existingResume != null) {
      _selectedExistingResume = widget.existingResume;
      _useExistingResume = true;
    } else {
      _useExistingResume = false;
    }
  }

  bool get _isOtherRole => _selectedRole == 'Other';

  String get _finalRole {
    if (_isOtherRole) {
      return _customRoleController.text.trim();
    }

    return _selectedRole ?? '';
  }

  bool get _hasResume {
    if (_useExistingResume) {
      return _selectedExistingResume != null;
    }

    return _uploadedResume != null;
  }

  bool get _canContinue {
    return _selectedRole != null &&
        _finalRole.isNotEmpty &&
        _hasResume &&
        !_isPickingFile;
  }

  @override
  void dispose() {
    _customRoleController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    setState(() {
      _isPickingFile = true;
    });

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: false,
      );

      if (!mounted) return;

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;

      setState(() {
        _uploadedResume = file;
        _useExistingResume = false;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select resume: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  void _selectExistingResume(InterviewResumeOption resume) {
    setState(() {
      _selectedExistingResume = resume;
      _useExistingResume = true;
      _uploadedResume = null;
    });
  }

  void _selectNewResume() {
    setState(() {
      _useExistingResume = false;
    });

    _pickResume();
  }

  void _continue() {
    if (!_canContinue) {
      String message = 'Please complete all required fields.';

      if (_selectedRole == null) {
        message = 'Please select an interview role.';
      } else if (_isOtherRole &&
          _customRoleController.text.trim().isEmpty) {
        message = 'Please enter your desired role.';
      } else if (!_hasResume) {
        message = 'Please select or upload a resume.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _background,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      InterviewSetupResult(
        role: _finalRole,
        existingResume:
        _useExistingResume ? _selectedExistingResume : null,
        uploadedResume:
        _useExistingResume ? null : _uploadedResume,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: _background.withOpacity(0.96),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.28),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildHeader(),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    icon: Icons.work_outline_rounded,
                    title: 'Choose your interview role',
                    subtitle:
                    'We will tailor the questions to your target role.',
                  ),

                  const SizedBox(height: 14),

                  _buildRoleDropdown(),

                  if (_isOtherRole) ...[
                    const SizedBox(height: 14),
                    _buildCustomRoleField(),
                  ],

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    icon: Icons.description_outlined,
                    title: 'Choose your resume',
                    subtitle:
                    'Use your saved resume or upload a new PDF.',
                  ),

                  const SizedBox(height: 14),

                  ..._buildExistingResumeCards(),

                  const SizedBox(height: 12),

                  _buildUploadResumeCard(),

                  if (!_useExistingResume &&
                      _uploadedResume != null) ...[
                    const SizedBox(height: 12),
                    _buildSelectedFileInfo(),
                  ],

                  const SizedBox(height: 28),

                  _buildContinueButton(),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      'Your interview will be personalized to your role and resume.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted.withOpacity(0.85),
                        fontSize: 11.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9A8CFF),
                Color(0xFF6A5AE0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.record_voice_over_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set up your interview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Let’s prepare you for your next opportunity.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.close_rounded,
            color: _muted,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _accent, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          dropdownColor: const Color(0xFF25253C),
          borderRadius: BorderRadius.circular(16),
          hint: const Text(
            'Select a role',
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _muted,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          items: _roles.map((role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
              if (value != 'Other') {
                _customRoleController.clear();
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildCustomRoleField() {
    return TextField(
      controller: _customRoleController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Enter your role, e.g. AI Research Engineer',
        hintStyle: const TextStyle(
          color: _muted,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.edit_outlined,
          color: _accent,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.055),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _accent,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExistingResumeCards() {
    final resumes = widget.resumes.isNotEmpty
        ? widget.resumes
        : (widget.existingResume != null ? [widget.existingResume!] : <InterviewResumeOption>[]);

    if (resumes.isEmpty) {
      return [
        _resumeOptionCard(
          selected: false,
          enabled: false,
          icon: Icons.description_rounded,
          title: 'No saved resume found',
          subtitle: 'Upload a PDF resume to continue',
          trailing: const Icon(
            Icons.info_outline_rounded,
            color: Colors.white30,
            size: 22,
          ),
          onTap: null,
        ),
      ];
    }

    return resumes.map((resume) {
      final isSelected = _useExistingResume && _selectedExistingResume?.id == resume.id;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _resumeOptionCard(
          selected: isSelected,
          enabled: true,
          icon: Icons.description_rounded,
          title: resume.title,
          subtitle: resume.subtitle ?? 'Your resume saved in Preply',
          trailing: isSelected
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: _accent,
                  size: 23,
                )
              : const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: _muted,
                  size: 22,
                ),
          onTap: () => _selectExistingResume(resume),
        ),
      );
    }).toList();
  }

  Widget _buildUploadResumeCard() {
    final isSelected = !_useExistingResume;

    return _resumeOptionCard(
      selected: isSelected,
      enabled: true,
      icon: Icons.cloud_upload_outlined,
      title: 'Upload new resume',
      subtitle: 'Choose a PDF file from your device',
      trailing: _isPickingFile
          ? const SizedBox(
        width: 21,
        height: 21,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _accent,
        ),
      )
          : Icon(
        isSelected
            ? Icons.check_circle_rounded
            : Icons.add_circle_outline_rounded,
        color: isSelected ? _accent : _muted,
        size: 23,
      ),
      onTap: _isPickingFile ? null : _selectNewResume,
    );
  }

  Widget _resumeOptionCard({
    required bool selected,
    required bool enabled,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected
            ? _accent.withOpacity(0.12)
            : Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? _accent.withOpacity(0.8)
              : Colors.white.withOpacity(0.11),
          width: selected ? 1.3 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  height: 43,
                  width: 43,
                  decoration: BoxDecoration(
                    color: selected
                        ? _accent.withOpacity(0.18)
                        : Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? _accent : Colors.white30,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: enabled ? Colors.white : Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileInfo() {
    final file = _uploadedResume!;

    final sizeInKb = file.size / 1024;
    final sizeLabel = sizeInKb >= 1024
        ? '${(sizeInKb / 1024).toStringAsFixed(2)} MB'
        : '${sizeInKb.toStringAsFixed(0)} KB';

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF31C48D).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF31C48D).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf_rounded,
            color: Color(0xFF31C48D),
            size: 23,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sizeLabel,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove file',
            onPressed: () {
              setState(() {
                _uploadedResume = null;
                _useExistingResume = _selectedExistingResume != null;
              });
            },
            icon: const Icon(
              Icons.close_rounded,
              color: _muted,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _canContinue
              ? const LinearGradient(
            colors: [
              Color(0xFF9A8CFF),
              Color(0xFF6A5AE0),
            ],
          )
              : LinearGradient(
            colors: [
              Colors.grey.shade700,
              Colors.grey.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _canContinue
              ? [
            BoxShadow(
              color: _accent.withOpacity(0.22),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: _canContinue ? _continue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Continue to interview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 9),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withOpacity(0.95),
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}