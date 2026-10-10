// lib/screens/Resume/components/ats_resume_sheet.dart

import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<PlatformFile?> showAtsResumeSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<PlatformFile>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (_) => const AtsResumeSheet(),
  );
}

class AtsResumeSheet extends StatefulWidget {
  const AtsResumeSheet({super.key});

  @override
  State<AtsResumeSheet> createState() => _AtsResumeSheetState();
}

class _AtsResumeSheetState extends State<AtsResumeSheet> {
  static const Color _background = Color(0xFF171729);
  static const Color _accent = Color(0xFF8B7CFF);
  static const Color _muted = Color(0xFFAAAAC4);
  static const Color _success = Color(0xFF31C48D);

  PlatformFile? _selectedResume;
  bool _isPickingFile = false;

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

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _selectedResume = result.files.single;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select resume: $error'),
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

  void _continue() {
    final resume = _selectedResume;
    if (resume == null) return;

    Navigator.of(context).pop(resume);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.48,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 18,
              sigmaY: 18,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: _background.withOpacity(0.97),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  22,
                  12,
                  22,
                  28,
                ),
                children: [
                  _buildDragHandle(),
                  const SizedBox(height: 25),
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildUploadArea(),
                  const SizedBox(height: 20),
                  _buildRequirements(),
                  if (_selectedResume != null) ...[
                    const SizedBox(height: 22),
                    _buildSelectedResume(),
                  ],
                  const SizedBox(height: 28),
                  _buildContinueButton(),
                  const SizedBox(height: 13),
                  const Text(
                    'Your resume will be analyzed for ATS compatibility, '
                        'skills, keywords, formatting, and improvement areas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                      height: 1.5,
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

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 42,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.28),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
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
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.analytics_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check your ATS score',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Upload your resume and discover how to improve it.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12.5,
                  height: 1.5,
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

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _isPickingFile ? null : _pickResume,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 28,
        ),
        decoration: BoxDecoration(
          color: _accent.withOpacity(0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _accent.withOpacity(0.55),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: _isPickingFile
                    ? const SizedBox(
                  width: 27,
                  height: 27,
                  child: CircularProgressIndicator(
                    color: _accent,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Icon(
                  Icons.cloud_upload_rounded,
                  color: _accent,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _selectedResume == null
                  ? 'Upload your resume'
                  : 'Choose a different resume',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap here to browse files on your device',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: _accent,
                    size: 17,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'PDF files only',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirements() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you will get',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 13),
          _RequirementRow(
            icon: Icons.speed_rounded,
            text: 'ATS compatibility score',
          ),
          SizedBox(height: 10),
          _RequirementRow(
            icon: Icons.key_rounded,
            text: 'Skills and missing keywords',
          ),
          SizedBox(height: 10),
          _RequirementRow(
            icon: Icons.trending_up_rounded,
            text: 'Personalized improvement suggestions',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedResume() {
    final resume = _selectedResume!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _success.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf_rounded,
            color: _success,
            size: 27,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resume.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatFileSize(resume.size),
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove resume',
            onPressed: () {
              setState(() {
                _selectedResume = null;
              });
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final enabled = _selectedResume != null && !_isPickingFile;

    return SizedBox(
      height: 54,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
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
          boxShadow: enabled
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
          onPressed: enabled ? _continue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Analyze my resume',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 9),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RequirementRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF8B7CFF),
          size: 17,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFAAAAC4),
              fontSize: 11.5,
            ),
          ),
        ),
      ],
    );
  }
}