import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:preply/screens/profile/components/profile_edit.dart';

class ProfileCard extends StatelessWidget {
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

  final VoidCallback? onDelete;

  const ProfileCard({
    super.key,
    this.name = '',
    this.email = '',
    this.profileImageUrl,
    this.education = const [],
    this.experience = const [],
    this.skills = const [],
    this.onSave,
    this.onDelete,
  });

  Future<void> _openEditor(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => ProfileEditSheet(
        name: name,
        email: email,
        profileImageUrl: profileImageUrl,
        education: education,
        experience: experience,
        skills: skills,
        onSave: onSave,
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF211B35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Delete profile?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete your profile? '
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _avatar(size: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? 'Your Profile' : name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Three-dot menu
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    color: const Color(0xFF211B35),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openEditor(context);
                      } else if (value == 'delete') {
                        _confirmDelete(context);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: Colors.white70,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              size: 19,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Delete Profile',
                              style: TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _heading('Education'),
              const SizedBox(height: 12),
              if (education.isEmpty)
                _empty('No education details added.')
              else
                ...education.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _section(
                        Icons.school_rounded,
                        item['degree']?.toString() ?? '',
                        item['fieldOfStudy']?.toString() ?? '',
                        item['institution']?.toString() ?? '',
                        '${item['startYear'] ?? ''} - '
                        '${item['endYear'] ?? ''}',
                      ),
                    )),
              const SizedBox(height: 8),
              _heading('Experience'),
              const SizedBox(height: 12),
              if (experience.isEmpty)
                _empty('No experience details added.')
              else
                ...experience.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _section(
                        Icons.work_rounded,
                        item['role']?.toString() ?? '',
                        item['company']?.toString() ?? '',
                        item['description']?.toString() ?? '',
                        '${item['startDate'] ?? ''} - '
                        '${item['endDate'] ?? 'Present'}',
                      ),
                    )),
              const SizedBox(height: 8),
              _heading('Skills'),
              const SizedBox(height: 12),
              if (skills.isEmpty)
                _empty('No skills added.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((skill) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.deepPurpleAccent.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: profileImageUrl != null && profileImageUrl!.isNotEmpty
            ? (profileImageUrl!.startsWith('data:')
                ? Image.memory(
                    base64Decode(profileImageUrl!.split(',')[1]),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarFallback(),
                  )
                : Image.network(
                    profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarFallback(),
                  ))
            : _avatarFallback(),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: Colors.deepPurple.withOpacity(0.2),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _heading(String title) => Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _empty(String message) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      );

  Widget _section(
    IconData icon,
    String title,
    String content,
    String subtitle,
    String date,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.deepPurpleAccent,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
